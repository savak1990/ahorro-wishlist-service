output "wishlist_lambda_app_name" {
  value = aws_lambda_function.app.function_name
}

output "wishlist_lambda_app_invoke_arn" {
  value = aws_lambda_function.app.invoke_arn
}
