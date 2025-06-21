provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "ahorro-app"
      Service     = "ahorro-wishlist-service"
      Terraform   = "true"
    }
  }
}

data "aws_secretsmanager_secret" "ahorro_app" {
  name = local.secret_name
}

data "aws_secretsmanager_secret_version" "ahorro_app" {
  secret_id = data.aws_secretsmanager_secret.ahorro_app.id
}

data "aws_acm_certificate" "cert" {
  domain      = "*.${local.domain_name}"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "public" {
  name         = local.domain_name
  private_zone = false
}

locals {
  base_name         = "${var.app_name}-${var.service_name}-${var.env}"
  app_lambda_name   = "${local.base_name}-app-lambda"
  db_table_name     = "${local.base_name}-db"
  secret_name       = "${var.app_name}-app-secrets"
  ahorro_app_secret = jsondecode(data.aws_secretsmanager_secret_version.ahorro_app.secret_string)
  domain_name       = local.ahorro_app_secret["domain_name"]
  full_api_name     = "api-${var.app_name}-${var.service_name}-${var.env}"
}

module "database" {
  source               = "../terraform/dynamodb"
  db_table_name        = local.db_table_name
  dbstream_handler_zip = var.dbstream_handler_zip
}

module "iam" {
  source        = "../terraform/iam"
  db_table_name = local.db_table_name
}

module "ahorro_wishlist_service" {
  source = "../terraform/service"

  db_table_name       = local.db_table_name
  app_lambda_name     = local.app_lambda_name
  app_handler_zip     = var.app_handler_zip
  app_lambda_role_arn = module.iam.app_lambda_role_arn
  api_name            = local.full_api_name
  stage_name          = var.env
  domain_name         = local.domain_name
  certificate_arn     = data.aws_acm_certificate.cert.arn
  zone_id             = data.aws_route53_zone.public.zone_id

  depends_on = [module.database, module.iam]
}

terraform {
  backend "s3" {
    bucket = "ahorro-app-state"
    # Update the key if you want to store the state in a different path
    key            = "dev/ahorro-wishlist-service/savak/terraform.tfstate"
    region         = "eu-west-1"
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
