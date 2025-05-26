provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "ahorro-app"
      Service     = "ahorro-wishlist-service"
      Terraform   = "true"
    }
  }
}

variable "db_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

module "service_db" {
  source        = "../terraform"
  db_table_name = var.db_table_name
}
