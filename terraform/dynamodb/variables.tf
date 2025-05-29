variable "db_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "db_read_capacity_min" {
  description = "The read capacity for the DynamoDB table"
  type        = number
  default     = 1
}

variable "db_read_capacity_max" {
  description = "The maximum read capacity for the DynamoDB table"
  type        = number
  default     = 5
}

variable "db_write_capacity_min" {
  description = "The write capacity for the DynamoDB table"
  type        = number
  default     = 1
}

variable "db_write_capacity_max" {
  description = "The maximum write capacity for the DynamoDB table"
  type        = number
  default     = 5
}
