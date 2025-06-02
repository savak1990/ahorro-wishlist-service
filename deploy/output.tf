output "db_table_name" {
  value = module.ahorro_wishlist_service_primary.db_table_name
}

output "db_table_arn_primary" {
  value = module.ahorro_wishlist_service_primary.db_table_arn
}

output "db_table_arn_secondary_1" {
  value = module.ahorro_wishlist_service_secondary_1.db_table_arn
}

output "lambda_dbstream_function_name" {
  value = module.ahorro_wishlist_service_primary.lambda_dbstream_function_name
}
