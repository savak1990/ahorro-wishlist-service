variable "db_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "db_app_handler_policy_arn" {
  description = "The ARN of the IAM policy for the app handler"
  type        = string
}
