locals {
  app_db_service_policy_name = "${var.db_table_name}-service-access"

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
          "arn:aws:dynamodb:*:*:table/${var.db_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.db_table_name}/index/*"
        ]
      }
    ]
  })
}
