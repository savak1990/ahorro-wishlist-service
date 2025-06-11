variable "db_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "dbstream_handler_zip" {
  description = "The path to the Lambda function zip file for the DB stream handler"
  type        = string
}
