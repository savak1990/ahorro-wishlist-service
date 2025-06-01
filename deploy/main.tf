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
  source               = "../terraform"
  app_name             = var.app_name
  service_name         = var.service_name
  env                  = var.env
  dbstream_handler_zip = var.dbstream_handler_zip
}

terraform {
  backend "s3" {
    bucket = "ahorro-app-terraform-state"
    # key is set in the makefile and passed as a backend-config variable
    region         = "us-east-1"
    dynamodb_table = "ahorro-app-state-lock"
    encrypt        = true
  }
}
