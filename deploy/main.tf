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

module "ahorro_wishlist_service" {
  source        = "../terraform"
  db_table_name = var.db_table_name
}
