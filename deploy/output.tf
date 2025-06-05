output "db_table_name" {
  value = local.db_table_name
}

output "db_global_table_arn" {
  value = module.database.table_arn
}

output "alb_dns_name_primary" {
  value = module.ahorro_wishlist_service_primary.alb_dns_name
}

output "alb_dns_name_secondary" {
  value = module.ahorro_wishlist_service_replica.alb_dns_name
}
