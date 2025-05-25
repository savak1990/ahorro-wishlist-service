resource "aws_dynamodb_table" "example" {
  name         = var.db_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "wishId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "wishId"
    type = "S"
  }
}
