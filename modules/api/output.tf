
output "id" {
  value = aws_api_gateway_rest_api.this.id
}

output "name" {
  value = aws_api_gateway_rest_api.this.name
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.this.root_resource_id
}

output "validator" {
  value = aws_api_gateway_request_validator.this.id
}

