output "table_arn" {
  value = aws_dynamodb_table.database.arn
}

output "gsi_names" {
  value = [for gsi in aws_dynamodb_table.database.global_secondary_index : gsi.name]
}

output "lsi_names" {
  value = [for lsi in aws_dynamodb_table.database.local_secondary_index : lsi.name]
}
