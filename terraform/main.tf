locals {
  db_table_name                       = "${var.app_name}-${var.service_name}-${var.env}-db"
  lambda_dbstream_handler_name        = "${var.app_name}-${var.service_name}-${var.env}-dbstream-lambda"
  alb_name                            = "${var.app_name}-${var.service_name}-${var.env}-alb"
  target_group_name                   = "${var.app_name}-${var.service_name}-${var.env}-tg"
  lambda_app_handler_name             = "${var.app_name}-${var.service_name}-${var.env}-app-handler"
  dynamodb_service_access_policy_name = "${var.app_name}-${var.service_name}-${var.env}-db-access-policy"
}

# Create the DynamoDB table only if this is the primary module
module "database" {
  count         = var.is_primary ? 1 : 0
  source        = "./modules/dynamodb"
  db_table_name = local.db_table_name
}

# Get global table ARN from the primary module if this is a secondary module
data "aws_dynamodb_table" "primary_table" {
  count    = var.is_primary ? 0 : 1
  name     = local.db_table_name
  provider = aws.primary
}

resource "aws_dynamodb_table_replica" "replica" {
  count            = var.is_primary ? 0 : 1
  global_table_arn = data.aws_dynamodb_table.primary_table[0].arn
}

module "dbstream_handler_lambda" {
  count                = var.is_primary ? 1 : 0
  source               = "./modules/lambda"
  lambda_function_name = local.lambda_dbstream_handler_name
  lambda_zip           = var.dbstream_handler_zip
  lambda_role_arn      = var.dbstream_lambda_role_arn
}

resource "aws_lambda_event_source_mapping" "db_stream_handler" {
  count             = var.is_primary ? 1 : 0
  event_source_arn  = module.database[0].db_stream_arn
  function_name     = module.dbstream_handler_lambda[0].lambda_function_name
  starting_position = "LATEST"
}

module "app_handler" {
  source               = "./modules/lambda"
  lambda_function_name = local.lambda_app_handler_name
  lambda_zip           = var.app_handler_zip
  lambda_role_arn      = var.app_lambda_role_arn
  lambda_environment_variables = {
    DYNAMODB_TABLE = local.db_table_name
    # Add your env vars here
  }
  depends_on = [module.database, aws_dynamodb_table_replica.replica]
}

module "alb" {
  source               = "./modules/alb"
  alb_name             = local.alb_name
  target_group_name    = local.target_group_name
  vpc_id               = var.alb_vpc_id
  subnet_ids           = var.alb_subnet_ids
  lambda_function_name = module.app_handler.lambda_function_name
  lambda_function_arn  = module.app_handler.lambda_function_arn
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.primary]
    }
  }
}
