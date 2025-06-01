resource "aws_dynamodb_table_replica" "replica" {
  global_table_arn = var.db_table_arn
}
