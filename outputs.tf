# Output value definitions

output "base_url" {
    description = "URL: "
    value = aws_api_gateway_deployment.webshopapi.invoke_url
}