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
  name           = var.db_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.db_read_capacity_min
  write_capacity = var.db_write_capacity_min

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
    read_capacity   = var.db_read_capacity_min
    write_capacity  = var.db_write_capacity_min
  }

  global_secondary_index {
    name            = local.db_gsi_all_priority
    hash_key        = "all"
    range_key       = "priority"
    projection_type = "ALL"
    read_capacity   = var.db_read_capacity_min
    write_capacity  = var.db_write_capacity_min
  }

  global_secondary_index {
    name            = local.db_gsi_all_due
    hash_key        = "all"
    range_key       = "due"
    projection_type = "ALL"
    read_capacity   = var.db_read_capacity_min
    write_capacity  = var.db_write_capacity_min
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

module "db_read_autoscaling" {
  source = "../autoscaling"

  service_namespace      = "dynamodb"
  resource_id            = "table/${aws_dynamodb_table.database.name}"
  scalable_dimension     = "dynamodb:table:ReadCapacityUnits"
  min_capacity           = var.db_read_capacity_min
  max_capacity           = var.db_read_capacity_max
  policy_name            = "ReadCapacityPolicy"
  policy_type            = "TargetTrackingScaling"
  target_value           = 70.0
  scale_in_cooldown      = 60
  scale_out_cooldown     = 60
  predefined_metric_type = "DynamoDBReadCapacityUtilization"
}

module "db_write_autoscaling" {
  source = "../autoscaling"

  service_namespace      = "dynamodb"
  resource_id            = "table/${aws_dynamodb_table.database.name}"
  scalable_dimension     = "dynamodb:table:WriteCapacityUnits"
  min_capacity           = var.db_write_capacity_min
  max_capacity           = var.db_write_capacity_max
  policy_name            = "WriteCapacityPolicy"
  policy_type            = "TargetTrackingScaling"
  target_value           = 70.0
  scale_in_cooldown      = 60
  scale_out_cooldown     = 60
  predefined_metric_type = "DynamoDBWriteCapacityUtilization"
}

module "gsi_created_read_autoscaling" {
  source = "../autoscaling"

  service_namespace      = "dynamodb"
  resource_id            = "table/${aws_dynamodb_table.database.name}/index/${local.db_gsi_all_created}"
  scalable_dimension     = "dynamodb:index:ReadCapacityUnits"
  min_capacity           = var.db_read_capacity_min
  max_capacity           = var.db_read_capacity_max
  policy_name            = "GSICreatedReadCapacityPolicy"
  policy_type            = "TargetTrackingScaling"
  target_value           = 70.0
  scale_in_cooldown      = 60
  scale_out_cooldown     = 60
  predefined_metric_type = "DynamoDBReadCapacityUtilization"
}

module "gsi_priority_read_autoscaling" {
  source = "../autoscaling"

  service_namespace      = "dynamodb"
  resource_id            = "table/${aws_dynamodb_table.database.name}/index/${local.db_gsi_all_priority}"
  scalable_dimension     = "dynamodb:index:ReadCapacityUnits"
  min_capacity           = var.db_read_capacity_min
  max_capacity           = var.db_read_capacity_max
  policy_name            = "GSIPriorityReadCapacityPolicy"
  policy_type            = "TargetTrackingScaling"
  target_value           = 70.0
  scale_in_cooldown      = 60
  scale_out_cooldown     = 60
  predefined_metric_type = "DynamoDBReadCapacityUtilization"
}

module "gsi_due_read_autoscaling" {
  source = "../autoscaling"

  service_namespace      = "dynamodb"
  resource_id            = "table/${aws_dynamodb_table.database.name}/index/${local.db_gsi_all_due}"
  scalable_dimension     = "dynamodb:index:ReadCapacityUnits"
  min_capacity           = var.db_read_capacity_min
  max_capacity           = var.db_read_capacity_max
  policy_name            = "GSIDueReadCapacityPolicy"
  policy_type            = "TargetTrackingScaling"
  target_value           = 70.0
  scale_in_cooldown      = 60
  scale_out_cooldown     = 60
  predefined_metric_type = "DynamoDBReadCapacityUtilization"
}
