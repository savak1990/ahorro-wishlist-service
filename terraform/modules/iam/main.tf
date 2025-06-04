locals {
  db_table_name              = "${var.app_name}-${var.service_name}-${var.env}-db"
  app_lambda_role            = "${var.app_name}-${var.service_name}-${var.env}-role"
  app_db_service_policy_name = "${var.app_name}-${var.service_name}-${var.env}-dynamodb-service-access"
  dbstream_lambda_role       = "${var.app_name}-${var.service_name}-${var.env}-dbstream-role"
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

# Create IAM roles for Lambda function
resource "aws_iam_role" "app_lambda_role" {
  name               = local.app_lambda_role
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "app_lambda_exec_policy_attachment" {
  role       = aws_iam_role.app_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "app_lambda_db_policy_attachment" {
  role       = aws_iam_role.app_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_service_access.arn
}

resource "aws_iam_policy" "dynamodb_service_access" {
  name        = local.app_db_service_policy_name
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
          "arn:aws:dynamodb:*:*:table/${local.db_table_name}",
          "arn:aws:dynamodb:*:*:table/${local.db_table_name}/index/*"
        ]
      }
    ]
  })
}

# Create IAM role for DB stream handler Lambda function
resource "aws_iam_role" "dbstream_lambda_role" {
  name               = local.dbstream_lambda_role
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "dbstream_lambda_exec_policy_attachment" {
  role       = aws_iam_role.app_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dbstream_lambda_db_policy_attachment" {
  role       = aws_iam_role.dbstream_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
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
