locals {
  lambda_function_role_name = "${var.lambda_function_name}-role"
}

data "aws_iam_role" "lambda_role" {
  count = var.is_primary ? 0 : 1
  name  = local.lambda_function_role_name
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

resource "aws_lambda_function" "lambda" {
  function_name    = var.lambda_function_name
  role             = var.is_primary ? aws_iam_role.lambda_role[0].arn : data.aws_iam_role.lambda_role[0].arn
  handler          = "bootstrap"
  runtime          = "provided.al2"
  filename         = var.lambda_zip
  source_code_hash = filebase64sha256(var.lambda_zip)

  environment {
    variables = var.lambda_environment_variables
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role" "lambda_role" {
  count              = var.is_primary ? 1 : 0
  name               = local.lambda_function_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  count      = var.is_primary ? 1 : 0
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_db_policy" {
  count      = var.is_primary ? 1 : 0
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

resource "aws_iam_role_policy_attachment" "extra" {
  count      = var.is_primary ? length(var.extra_policy_arns) : 0
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = var.extra_policy_arns[count.index]
}
