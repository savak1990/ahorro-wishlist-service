output "db_table_name" {
  value = var.db_replica_table_arn != null ? module.database_replica[0].db_table_name : module.database[0].db_table_name
}

output "db_table_arn" {
  value = var.db_replica_table_arn != null ? module.database_replica[0].db_table_arn : module.database[0].db_table_arn
}

output "lambda_function_name" {
  value = module.dbstream_handler_lambda.lambda_function_name
}

output "lambda_function_arn" {
  value = module.dbstream_handler_lambda.lambda_function_arn
}
