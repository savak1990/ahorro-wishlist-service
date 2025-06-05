locals {
  dbstream_lambda_role         = "${var.db_table_name}-stream-role"
  lambda_dbstream_handler_name = "${var.db_table_name}-stream-lambda"

  # Global Secondary Index (GSI)
  db_gsi_all_created  = "${var.db_table_name}-gsi-all-created"
  db_gsi_all_priority = "${var.db_table_name}-gsi-all-priority"
  db_gsi_all_due      = "${var.db_table_name}-gsi-all-due"

  # Local Secondary Index (LSI) names
  db_lsi_created  = "${var.db_table_name}-lsi-created"
  db_lsi_priority = "${var.db_table_name}-lsi-priority"
  db_lsi_due      = "${var.db_table_name}-lsi-due"
}

resource "aws_dynamodb_table" "database" {
  name         = var.db_table_name
  billing_mode = "PAY_PER_REQUEST"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  hash_key  = "userId"
  range_key = "wishId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "wishId"
    type = "S"
  }

  attribute {
    name = "created"
    type = "S"
  }

  attribute {
    name = "due"
    type = "S"
  }

  attribute {
    name = "priority"
    type = "N"
  }

  attribute {
    name = "all"
    type = "S"
  }

  global_secondary_index {
    name            = local.db_gsi_all_created
    hash_key        = "all"
    range_key       = "created"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = local.db_gsi_all_priority
    hash_key        = "all"
    range_key       = "priority"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = local.db_gsi_all_due
    hash_key        = "all"
    range_key       = "due"
    projection_type = "ALL"
  }

  local_secondary_index {
    name            = local.db_lsi_created
    range_key       = "created"
    projection_type = "ALL"
  }

  local_secondary_index {
    name            = local.db_lsi_priority
    range_key       = "priority"
    projection_type = "ALL"
  }

  local_secondary_index {
    name            = local.db_lsi_due
    range_key       = "due"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "expires"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  replica {
    region_name = var.replica_region
  }

  lifecycle {
    # enable this to prevent accidental deletion of the table
    # prevent_destroy = true

    # Without this change, each time you do deploy, it will try to put some changes
    # to the stream, and it will cause recreation of the replica table. Comment
    # it out if you really want to change this setting.
    ignore_changes = [
      stream_enabled,
    ]
  }
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

resource "aws_iam_role" "dbstream_lambda_role" {
  name               = local.dbstream_lambda_role
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "dbstream_lambda_exec_policy_attachment" {
  role       = aws_iam_role.dbstream_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dbstream_lambda_db_policy_attachment" {
  role       = aws_iam_role.dbstream_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

resource "aws_lambda_function" "lambda" {
  function_name    = local.lambda_dbstream_handler_name
  role             = aws_iam_role.dbstream_lambda_role.arn
  handler          = "bootstrap"
  runtime          = "provided.al2"
  filename         = var.dbstream_handler_zip
  source_code_hash = filebase64sha256(var.dbstream_handler_zip)
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_event_source_mapping" "db_stream_handler" {
  event_source_arn  = aws_dynamodb_table.database.stream_arn
  function_name     = aws_lambda_function.lambda.function_name
  starting_position = "LATEST"
}
