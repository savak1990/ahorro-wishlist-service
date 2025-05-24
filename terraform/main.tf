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
