locals {
  lambda_dbstream_handler_name        = "${var.base_name}-dbstream-lambda"
  alb_name                            = "${var.base_name}-alb"
  target_group_name                   = "${var.base_name}-tg"
  lambda_app_handler_name             = "${var.base_name}-app-handler"
  dynamodb_service_access_policy_name = "${var.base_name}-db-access-policy"
}

module "app_handler" {
  source               = "./modules/lambda"
  lambda_function_name = local.lambda_app_handler_name
  lambda_zip           = var.app_handler_zip
  lambda_role_arn      = var.app_lambda_role_arn
  lambda_environment_variables = {
    DYNAMODB_TABLE = var.db_table_name
    # Add your env vars here
  }
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
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}
