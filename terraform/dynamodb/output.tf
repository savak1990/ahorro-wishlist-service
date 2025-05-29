output "db_table_name" {
  value = aws_dynamodb_table.database.name
}

output "gsi_names" {
  value = [for gsi in aws_dynamodb_table.database.global_secondary_index : gsi.name]
}

output "lsi_names" {
  value = [for lsi in aws_dynamodb_table.database.local_secondary_index : lsi.name]
}
