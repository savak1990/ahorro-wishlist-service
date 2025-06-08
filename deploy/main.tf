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

data "aws_secretsmanager_secret" "ahorro_app" {
  name = "ahorro-app"
}

data "aws_secretsmanager_secret_version" "ahorro_app" {
  secret_id = data.aws_secretsmanager_secret.ahorro_app.id
}

locals {
  base_name         = "${var.app_name}-${var.service_name}-${var.env}"
  db_table_name     = "${local.base_name}-db"
  ahorro_app_secret = jsondecode(data.aws_secretsmanager_secret_version.ahorro_app.secret_string)
  domain_name       = local.ahorro_app_secret["domain_name"]
}

module "database" {
  source               = "../terraform/dynamodb"
  db_table_name        = local.db_table_name
  replica_region       = "eu-central-1"
  dbstream_handler_zip = var.dbstream_handler_zip
}

module "iam" {
  source        = "../terraform/iam"
  db_table_name = local.db_table_name
}

module "ahorro_wishlist_service_primary" {
  source = "../terraform/service"

  base_name           = local.base_name
  db_table_name       = local.db_table_name
  app_handler_zip     = var.app_handler_zip
  app_lambda_role_arn = module.iam.app_lambda_role_arn
  alb_subnet_ids      = data.aws_subnets.primary.ids
  alb_vpc_id          = data.aws_vpc.primary.id

  depends_on = [module.database, module.iam]
}

module "ahorro_wishlist_service_replica" {
  source = "../terraform/service"

  providers = {
    aws = aws.replica
  }

  base_name           = local.base_name
  db_table_name       = local.db_table_name
  app_handler_zip     = var.app_handler_zip
  app_lambda_role_arn = module.iam.app_lambda_role_arn
  alb_subnet_ids      = data.aws_subnets.replica.ids
  alb_vpc_id          = data.aws_vpc.replica.id

  depends_on = [module.database, module.iam]
}

data "aws_route53_zone" "public" {
  name         = local.domain_name
  private_zone = false
}

# Latency-based alias records for each ALB
resource "aws_route53_record" "wishlist_service" {
  count          = 2
  zone_id        = data.aws_route53_zone.public.zone_id
  name           = "api.${var.app_name}-${var.service_name}.${var.env}.${local.domain_name}"
  type           = "A"
  set_identifier = count.index == 0 ? "primary" : "replica"

  alias {
    name                   = count.index == 0 ? module.ahorro_wishlist_service_primary.alb_dns_name : module.ahorro_wishlist_service_replica.alb_dns_name
    zone_id                = count.index == 0 ? module.ahorro_wishlist_service_primary.alb_zone_id : module.ahorro_wishlist_service_replica.alb_zone_id
    evaluate_target_health = true
  }

  latency_routing_policy {
    region = count.index == 0 ? "us-east-1" : "eu-central-1"
  }
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
