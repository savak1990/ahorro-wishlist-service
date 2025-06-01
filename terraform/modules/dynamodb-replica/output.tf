output "replica_table_name" {
  value = aws_dynamodb_table_replica.replica.name
}

output "replica_table_arn" {
  value = aws_dynamodb_table_replica.replica.arn
}

output "replica_stream_arn" {
  value = aws_dynamodb_table_replica.replica.stream_arn
}
