variable "base_name" {
  description = "The base name for the application, used to construct resource names."
  type        = string
}

variable "db_table_name" {
  description = "The name of the DynamoDB table"
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

variable "dbstream_handler_zip" {
  description = "The path to the Lambda function zip file for the DB stream handler"
  type        = string
  default     = null
}

variable "dbstream_lambda_role_arn" {
  description = "The ARN of the IAM role for the DB stream handler Lambda function"
  type        = string
}

variable "alb_vpc_id" {
  description = "The VPC ID for the ALB."
  type        = string
}

variable "alb_subnet_ids" {
  description = "List of subnet IDs for the ALB."
  type        = list(string)
}
