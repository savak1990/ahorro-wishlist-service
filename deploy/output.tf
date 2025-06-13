output "db_table_name" {
  value = local.db_table_name
}

output "api_url" {
  value     = module.ahorro_wishlist_service.service_url
  sensitive = true
}
