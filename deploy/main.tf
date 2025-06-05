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

provider "aws" {
  region = "eu-central-1"
  alias  = "replica"

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
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_subnets" "replica" {
  provider = aws.replica
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_vpc" "primary" {
  default = true
}

data "aws_vpc" "replica" {
  provider = aws.replica
  default  = true
}

locals {
  base_name     = "${var.app_name}-${var.service_name}-${var.env}"
  db_table_name = "${local.base_name}-db"
}

module "database" {
  source               = "../terraform/modules/dynamodb"
  db_table_name        = local.db_table_name
  replica_region       = "eu-central-1"
  dbstream_handler_zip = var.dbstream_handler_zip
}

module "iam" {
  source        = "../terraform/modules/iam"
  db_table_name = local.db_table_name
}

module "ahorro_wishlist_service_primary" {
  source = "../terraform"

  base_name           = local.base_name
  db_table_name       = local.db_table_name
  app_handler_zip     = var.app_handler_zip
  app_lambda_role_arn = module.iam.app_lambda_role_arn
  alb_subnet_ids      = data.aws_subnets.primary.ids
  alb_vpc_id          = data.aws_vpc.primary.id
}

module "ahorro_wishlist_service_replica" {
  source = "../terraform"

  providers = {
    aws = aws.replica
  }

  base_name           = local.base_name
  db_table_name       = local.db_table_name
  app_handler_zip     = var.app_handler_zip
  app_lambda_role_arn = module.iam.app_lambda_role_arn
  alb_subnet_ids      = data.aws_subnets.replica.ids
  alb_vpc_id          = data.aws_vpc.replica.id

  depends_on = [module.database]
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
