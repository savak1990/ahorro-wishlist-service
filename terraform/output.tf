output "db_table_name" {
  value = module.database.db_table_name
}

output "gsi_names" {
  value = module.database.gsi_names
}

output "lsi_names" {
  value = module.database.lsi_names
}

output "lambda_function_name" {
  value = module.dbstream_handler_lambda.lambda_function_name
}

output "lambda_function_arn" {
  value = module.dbstream_handler_lambda.lambda_function_arn
}
