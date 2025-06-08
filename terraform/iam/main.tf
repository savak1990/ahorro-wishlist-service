locals {
  app_lambda_role            = "${var.db_table_name}-role"
  app_db_service_policy_name = "${var.db_table_name}-service-access"
  dbaccess_policy_name       = "${var.db_table_name}-access-policy"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_lambda_role" {
  name               = local.app_lambda_role
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "app_lambda_exec_policy_attachment" {
  role       = aws_iam_role.app_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "dynamodb_service_access" {
  name        = local.dbaccess_policy_name
  description = "Least-privilege DynamoDB access for Lambda to get and update items"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          "arn:aws:dynamodb:*:*:table/${var.db_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.db_table_name}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_lambda_db_policy_attachment" {
  role       = aws_iam_role.app_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_service_access.arn
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
