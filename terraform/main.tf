module "database" {
  source                = "./modules/dynamodb"
  db_table_name         = var.db_table_name
  db_read_capacity_min  = var.db_read_capacity_min
  db_read_capacity_max  = var.db_read_capacity_max
  db_write_capacity_min = var.db_write_capacity_min
  db_write_capacity_max = var.db_write_capacity_max
}
