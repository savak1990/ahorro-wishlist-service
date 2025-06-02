locals {
  db_table_name                = "${var.app_name}-${var.service_name}-${var.env}-db"
  lambda_dbstream_handler_name = "${var.app_name}-${var.service_name}-${var.env}-dbstream-lambda"
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
  is_primary           = var.is_primary
}

resource "aws_lambda_event_source_mapping" "db_stream_handler" {
  count             = var.is_primary ? 1 : 0
  event_source_arn  = module.database[0].db_stream_arn
  function_name     = module.dbstream_handler_lambda[0].lambda_function_name
  starting_position = "LATEST"
}

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.primary]
    }
  }
}
