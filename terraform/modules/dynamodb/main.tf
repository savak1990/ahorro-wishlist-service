locals {
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
}
