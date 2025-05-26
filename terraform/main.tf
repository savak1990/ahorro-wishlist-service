resource "aws_dynamodb_table" "database" {
  name           = var.db_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
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
}

resource "aws_appautoscaling_target" "read_capacity" {
  service_namespace  = "dynamodb"
  resource_id        = "table/${aws_dynamodb_table.database.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  min_capacity       = 1
  max_capacity       = 5
}

resource "aws_appautoscaling_policy" "read_capacity_policy" {
  name               = "ReadCapacityPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_capacity.resource_id
  scalable_dimension = aws_appautoscaling_target.read_capacity.scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_capacity.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "write_capacity" {
  service_namespace  = "dynamodb"
  resource_id        = "table/${aws_dynamodb_table.database.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  min_capacity       = 1
  max_capacity       = 5
}

resource "aws_appautoscaling_policy" "write_capacity_policy" {
  name               = "WriteCapacityPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_capacity.resource_id
  scalable_dimension = aws_appautoscaling_target.write_capacity.scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_capacity.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
  }
}
