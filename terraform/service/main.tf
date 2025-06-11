resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.app.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "app" {
  function_name    = var.app_lambda_name
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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}
