locals {
  db_table_name                = "${var.app_name}-${var.service_name}-${var.env}-db"
  lambda_dbstream_handler_name = "${var.app_name}-${var.service_name}-${var.env}-dbstream-lambda"
}

module "database" {
  count         = var.db_replica_table_arn == null ? 1 : 0
  source        = "./modules/dynamodb"
  db_table_name = local.db_table_name
}

module "database_replica" {
  count        = var.db_replica_table_arn != null ? 1 : 0
  source       = "./modules/dynamodb-replica"
  db_table_arn = var.db_replica_table_arn
}

module "dbstream_handler_lambda" {
  source               = "./modules/lambda"
  lambda_function_name = local.lambda_dbstream_handler_name
  lambda_zip           = var.dbstream_handler_zip
}

resource "aws_lambda_event_source_mapping" "db_stream_handler" {
  count             = var.db_replica_table_arn == null ? 1 : 0
  event_source_arn  = module.database[0].db_stream_arn
  function_name     = module.dbstream_handler_lambda.lambda_function_name
  starting_position = "LATEST"
}

resource "aws_lambda_event_source_mapping" "db_stream_handler_replica" {
  count             = var.db_replica_table_arn != null ? 1 : 0
  event_source_arn  = module.database_replica[0].replica_stream_arn
  function_name     = module.dbstream_handler_lambda.lambda_function_name
  starting_position = "LATEST"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
