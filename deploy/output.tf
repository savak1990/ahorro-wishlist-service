output "db_table_name" {
  value = module.service_db.db_table_name
}

output "gsi_names" {
  value = module.service_db.gsi_names
}

output "lsi_names" {
  value = module.service_db.lsi_names
}
