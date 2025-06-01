variable "db_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "db_replica_regions" {
  description = "List of regions for DynamoDB global tables"
  type        = list(string)
  default     = []
}
