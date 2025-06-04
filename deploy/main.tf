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
  alias  = "secondary"
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "ahorro-app"
      Service     = "ahorro-wishlist-service"
      Terraform   = "true"
    }
  }
}

data "aws_subnets" "primary" {
  provider = aws.primary
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_subnets" "secondary" {
  provider = aws.secondary
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_vpc" "primary" {
  provider = aws.primary
  default  = true
}

data "aws_vpc" "secondary" {
  provider = aws.secondary
  default  = true
}

module "iam" {
  source = "../terraform/modules/iam"
  providers = {
    aws = aws.primary
  }

  app_name     = var.app_name
  service_name = var.service_name
  env          = var.env
}

module "ahorro_wishlist_service_primary" {
  source = "../terraform"

  providers = {
    aws         = aws.primary
    aws.primary = aws.primary
  }

  is_primary               = true
  app_name                 = var.app_name
  service_name             = var.service_name
  env                      = var.env
  app_handler_zip          = var.app_handler_zip
  app_lambda_role_arn      = module.iam.app_lambda_role_arn
  dbstream_handler_zip     = var.dbstream_handler_zip
  dbstream_lambda_role_arn = module.iam.dbstream_lambda_role_arn
  alb_subnet_ids           = data.aws_subnets.primary.ids
  alb_vpc_id               = data.aws_vpc.primary.id
}

module "ahorro_wishlist_service_secondary_1" {
  source = "../terraform"

  providers = {
    aws         = aws.secondary
    aws.primary = aws.primary
  }

  is_primary               = false
  app_name                 = var.app_name
  service_name             = var.service_name
  env                      = var.env
  app_handler_zip          = var.app_handler_zip
  app_lambda_role_arn      = module.iam.app_lambda_role_arn
  dbstream_handler_zip     = var.dbstream_handler_zip
  dbstream_lambda_role_arn = module.iam.dbstream_lambda_role_arn
  alb_subnet_ids           = data.aws_subnets.secondary.ids
  alb_vpc_id               = data.aws_vpc.secondary.id

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
