variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_zip" {
  description = "The path to the Lambda function zip file"
  type        = string
}

variable "lambda_role_arn" {
  description = "The ARN of the IAM role for the Lambda function"
  type        = string
}

variable "lambda_environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}
