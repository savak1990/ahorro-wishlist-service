output "table_arn" {
  value = aws_dynamodb_table.database.arn
}

output "stream_arn" {
  value = aws_dynamodb_table.database.stream_arn
}

output "db_app_handler_policy_arn" {
  value = aws_iam_policy.dynamodb_service_access.arn
}

output "gsi_names" {
  value = [for gsi in aws_dynamodb_table.database.global_secondary_index : gsi.name]
}

output "lsi_names" {
  value = [for lsi in aws_dynamodb_table.database.local_secondary_index : lsi.name]
}
