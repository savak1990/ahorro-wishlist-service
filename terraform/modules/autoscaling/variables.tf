variable "service_namespace" {
  description = "The AWS service namespace, e.g., dynamodb, ecs"
  type        = string
}

variable "resource_id" {
  description = "The resource ID to scale (e.g., table/your-table-name or service/cluster/service-name)"
  type        = string
}

variable "scalable_dimension" {
  description = "The scalable dimension (e.g., dynamodb:table:ReadCapacityUnits)"
  type        = string
}

variable "min_capacity" {
  description = "Minimum capacity unit"
  type        = number
}

variable "max_capacity" {
  description = "Maximum capacity unit"
  type        = number
}

variable "policy_name" {
  description = "Name of the scaling policy"
  type        = string
}

variable "policy_type" {
  description = "Type of the scaling policy (e.g., TargetTrackingScaling)"
  type        = string
}

variable "target_value" {
  description = "The target value for the metric"
  type        = number
}

variable "scale_in_cooldown" {
  description = "Cooldown period (seconds) after a scale in activity"
  type        = number
}

variable "scale_out_cooldown" {
  description = "Cooldown period (seconds) after a scale out activity"
  type        = number
}

variable "predefined_metric_type" {
  description = "The metric type for target tracking (e.g., DynamoDBReadCapacityUtilization)"
  type        = string
}
