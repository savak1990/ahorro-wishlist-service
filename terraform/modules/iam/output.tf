output "app_lambda_role_arn" {
  value       = aws_iam_role.app_lambda_role.arn
  description = "The ARN of the app lambda role"
}

output "dbstream_lambda_role_arn" {
  value       = aws_iam_role.dbstream_lambda_role.arn
  description = "The ARN of the dbstream lambda role"
}
