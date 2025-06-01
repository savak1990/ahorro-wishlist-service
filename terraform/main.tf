locals {
  db_table_name                = "${var.app_name}-${var.service_name}-${var.env}-db"
  lambda_dbstream_handler_name = "${var.app_name}-${var.service_name}-${var.env}-dbstream-lambda"
}

module "database" {
  source             = "./modules/dynamodb"
  db_table_name      = local.db_table_name
  db_replica_regions = var.db_replica_regions
}

module "dbstream_handler_lambda" {
  source               = "./modules/lambda"
  lambda_function_name = local.lambda_dbstream_handler_name
  lambda_zip           = var.dbstream_handler_zip
}

resource "aws_lambda_event_source_mapping" "db_stream_handler" {
  event_source_arn  = module.database.db_stream_arn
  function_name     = module.dbstream_handler_lambda.lambda_function_name
  starting_position = "LATEST"
}
