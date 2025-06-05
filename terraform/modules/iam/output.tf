output "app_lambda_role_arn" {
  value       = aws_iam_role.app_lambda_role.arn
  description = "The ARN of the app lambda role"
}
