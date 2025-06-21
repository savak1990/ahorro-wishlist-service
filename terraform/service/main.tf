locals {
  openapi_template_path = "${path.module}/schema/openapi.yml.tmpl"
}

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

module "apigateway" {
  source                = "../../../ahorro-shared/terraform/apigateway"
  api_name              = var.api_name
  domain_name           = var.domain_name
  zone_id               = var.zone_id
  certificate_arn       = var.certificate_arn
  stage_name            = var.stage_name
  lambda_name           = aws_lambda_function.app.function_name
  lambda_invoke_arn     = aws_lambda_function.app.invoke_arn
  openapi_template_path = local.openapi_template_path
  openapi_template_replacements = {
    "lambda_invoke_arn" = aws_lambda_function.app.invoke_arn
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
