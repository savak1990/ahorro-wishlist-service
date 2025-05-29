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

module "service_db" {
  source              = "../terraform/dynamodb"
  db_table_name       = var.db_table_name
  db_gsi_all_created  = "${var.db_table_name}-gsi-all-created"
  db_gsi_all_priority = "${var.db_table_name}-gsi-all-priority"
  db_lsi_created      = "${var.db_table_name}-lsi-created"
  db_lsi_priority     = "${var.db_table_name}-lsi-priority"
}
