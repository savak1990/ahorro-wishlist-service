provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      Terraform   = "true"
    }
  }
}

resource "aws_dynamodb_table" "example" {
  name         = "AhorroWishlist"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }
}
