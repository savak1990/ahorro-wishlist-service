variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "service_name" {
  description = "The name of the service"
  type        = string
}

variable "env" {
  description = "The environment for the deployment (e.g., dev, prod, named env)"
  type        = string
}

variable "is_primary" {
  description = "If primary, the module will create the DynamoDB table and Lambda function for DB stream handling"
  type        = bool
  default     = false
}

variable "dbstream_handler_zip" {
  description = "The path to the Lambda function zip file for the DB stream handler"
  type        = string
  default     = null
}

variable "app_handler_zip" {
  description = "Path to the zipped Go Lambda handler for the app."
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
