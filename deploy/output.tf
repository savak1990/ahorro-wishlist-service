output "db_table_name" {
  value = local.db_table_name
}

output "api_url" {
  value     = module.apigateway.api_gateway_url
  sensitive = true
}
