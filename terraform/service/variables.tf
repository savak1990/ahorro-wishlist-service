variable "db_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "app_lambda_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "app_handler_zip" {
  description = "Path to the zipped Go Lambda handler for the app."
  type        = string
}

variable "app_lambda_role_arn" {
  description = "The ARN of the IAM role for the app Lambda function"
  type        = string
}
