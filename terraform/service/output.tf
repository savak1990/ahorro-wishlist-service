output "lambda_app_function_name" {
  value = local.lambda_app_handler_name
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_zone_id" {
  value = aws_lb.this.zone_id
}
