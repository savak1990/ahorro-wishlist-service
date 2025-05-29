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

variable "db_gsi_all_created" {
  description = "The name of the global secondary index for all created items"
  type        = string
}

variable "db_gsi_all_priority" {
  description = "The name of the global secondary index for all priority items"
  type        = string
}

variable "db_lsi_created" {
  description = "The name of the local secondary index for created items"
  type        = string
}

variable "db_lsi_priority" {
  description = "The name of the local secondary index for priority items"
  type        = string
}
