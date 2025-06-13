output "service_url" {
  description = "The URL of the ahorro wishlist service."
  value       = module.apigateway.api_gateway_url
}
