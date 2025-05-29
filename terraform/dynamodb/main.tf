resource "aws_dynamodb_table" "database" {
  name           = var.db_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.db_read_capacity_min
  write_capacity = var.db_write_capacity_min
  hash_key       = "userId"
  range_key      = "wishId"

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
    name = "priority"
    type = "N"
  }

  attribute {
    name = "all"
    type = "S"
  }

  global_secondary_index {
    name            = var.db_gsi_all_created
    hash_key        = "all"
    range_key       = "created"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }

  global_secondary_index {
    name            = var.db_gsi_all_priority
    hash_key        = "all"
    range_key       = "priority"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }

  local_secondary_index {
    name            = var.db_lsi_created
    range_key       = "created"
    projection_type = "ALL"
  }

  local_secondary_index {
    name            = var.db_lsi_priority
    range_key       = "priority"
    projection_type = "ALL"
  }
}

resource "aws_appautoscaling_target" "db_read_capacity" {
  service_namespace  = "dynamodb"
  resource_id        = "table/${aws_dynamodb_table.database.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  min_capacity       = var.db_read_capacity_min
  max_capacity       = var.db_read_capacity_max
}

resource "aws_appautoscaling_policy" "db_read_capacity_policy" {
  name               = "ReadCapacityPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.db_read_capacity.resource_id
  scalable_dimension = aws_appautoscaling_target.db_read_capacity.scalable_dimension
  service_namespace  = aws_appautoscaling_target.db_read_capacity.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "db_write_capacity" {
  service_namespace  = "dynamodb"
  resource_id        = "table/${aws_dynamodb_table.database.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  min_capacity       = var.db_write_capacity_min
  max_capacity       = var.db_write_capacity_max
}

resource "aws_appautoscaling_policy" "db_write_capacity_policy" {
  name               = "DBWriteCapacityPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.db_write_capacity.resource_id
  scalable_dimension = aws_appautoscaling_target.db_write_capacity.scalable_dimension
  service_namespace  = aws_appautoscaling_target.db_write_capacity.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "gsi_created_read_capacity" {
  service_namespace  = "dynamodb"
  resource_id        = "table/${aws_dynamodb_table.database.name}/index/${var.db_gsi_all_created}"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  min_capacity       = var.db_read_capacity_min
  max_capacity       = var.db_read_capacity_max
}

resource "aws_appautoscaling_policy" "gsi_created_read_capacity_policy" {
  name               = "GSICreatedReadCapacityPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.gsi_created_read_capacity.resource_id
  scalable_dimension = aws_appautoscaling_target.gsi_created_read_capacity.scalable_dimension
  service_namespace  = aws_appautoscaling_target.gsi_created_read_capacity.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "gsi_priority_read_capacity" {
  service_namespace  = "dynamodb"
  resource_id        = "table/${aws_dynamodb_table.database.name}/index/${var.db_gsi_all_priority}"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  min_capacity       = var.db_read_capacity_min
  max_capacity       = var.db_read_capacity_max
}

resource "aws_appautoscaling_policy" "gsi_priority_read_capacity_policy" {
  name               = "GSIPriorityReadCapacityPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.gsi_priority_read_capacity.resource_id
  scalable_dimension = aws_appautoscaling_target.gsi_priority_read_capacity.scalable_dimension
  service_namespace  = aws_appautoscaling_target.gsi_priority_read_capacity.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}
