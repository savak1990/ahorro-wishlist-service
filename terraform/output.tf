output "db_table_name" {
  value = local.db_table_name
}

output "db_table_arn" {
  value = length(module.database) > 0 ? module.database[0].db_table_arn : aws_dynamodb_table_replica.replica[0].arn
}

output "lambda_dbstream_function_name" {
  value = local.lambda_dbstream_handler_name
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
