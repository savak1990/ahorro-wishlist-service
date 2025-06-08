output "lambda_app_function_name" {
  value = local.lambda_app_handler_name
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
