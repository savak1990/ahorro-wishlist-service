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

variable "api_name" {
  description = "The name of the API Gateway."
  type        = string
}

variable "domain_name" {
  description = "The domain name of the API."
  type        = string
}

variable "zone_id" {
  description = "The Route53 hosted zone ID for the domain."
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate for the custom domain."
  type        = string
}

variable "stage_name" {
  description = "The name of the API Gateway stage."
  type        = string
}
