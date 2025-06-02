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
