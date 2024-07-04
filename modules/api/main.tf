resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = var.description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_request_validator" "this" {
  name                        = "${var.name}_validator"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = true
  validate_request_parameters = true
}