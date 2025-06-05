variable "db_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "replica_region" {
  description = "The AWS region for the DynamoDB replica"
  type        = string
}
