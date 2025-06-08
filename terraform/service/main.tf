locals {
  lambda_dbstream_handler_name        = "${var.base_name}-dbstream-lambda"
  alb_name                            = "${var.base_name}-alb"
  target_group_name                   = "${var.base_name}-tg"
  lambda_app_handler_name             = "${var.base_name}-app-handler"
  dynamodb_service_access_policy_name = "${var.base_name}-db-access-policy"
}

resource "aws_lambda_function" "lambda" {
  function_name    = local.lambda_app_handler_name
  role             = var.app_lambda_role_arn
  handler          = "bootstrap"
  runtime          = "provided.al2"
  filename         = var.app_handler_zip
  source_code_hash = filebase64sha256(var.app_handler_zip)

  environment {
    variables = {
      DYNAMODB_TABLE = var.db_table_name
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

module "alb" {
  source               = "./alb"
  alb_name             = local.alb_name
  target_group_name    = local.target_group_name
  vpc_id               = var.alb_vpc_id
  subnet_ids           = var.alb_subnet_ids
  lambda_function_name = aws_lambda_function.lambda.function_name
  lambda_function_arn  = aws_lambda_function.lambda.arn
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
