module "database" {
  source             = "./modules/dynamodb"
  db_table_name      = var.db_table_name
  db_replica_regions = var.db_replica_regions
}
