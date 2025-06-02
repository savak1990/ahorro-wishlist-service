provider "aws" {
  region = "us-east-1"
  alias  = "primary"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "ahorro-app"
      Service     = "ahorro-wishlist-service"
      Terraform   = "true"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  alias  = "secondary-1"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "ahorro-app"
      Service     = "ahorro-wishlist-service"
      Terraform   = "true"
    }
  }
}

module "ahorro_wishlist_service_primary" {
  source = "../terraform"

  providers = {
    aws         = aws.primary
    aws.primary = aws.primary
  }

  app_name             = var.app_name
  service_name         = var.service_name
  env                  = var.env
  dbstream_handler_zip = var.dbstream_handler_zip
  is_primary           = true
}

module "ahorro_wishlist_service_secondary_1" {
  source = "../terraform"

  providers = {
    aws         = aws.secondary-1
    aws.primary = aws.primary
  }

  app_name     = var.app_name
  service_name = var.service_name
  env          = var.env
  is_primary   = false

  depends_on = [module.ahorro_wishlist_service_primary]
}

terraform {
  backend "s3" {
    bucket = "ahorro-app-terraform-state"
    # key is set in the makefile and passed as a backend-config variable
    region         = "us-east-1"
    dynamodb_table = "ahorro-app-state-lock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
