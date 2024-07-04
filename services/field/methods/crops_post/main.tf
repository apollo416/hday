
module "lambda" {
  source  = "../../../../modules/lambda"
  service = "field"
  name    = "crops_post"
  key     = var.key
  signer  = var.signer
  api     = var.api
}

resource "aws_api_gateway_method" "this" {
  # checkov:skip=CKV_AWS_59:Ensure there is no open access to backend resources through API
  rest_api_id   = var.api
  resource_id   = var.resource
  http_method   = "POST"
  authorization = "NONE"
  request_models = {
    "application/json" = "Empty"
  }
  request_validator_id = var.validator
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = var.api
  resource_id             = var.resource
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "http_200" {
  rest_api_id = var.api
  resource_id = var.resource
  http_method = aws_api_gateway_method.this.http_method
  status_code = "200"
  response_models = {
    "application/json" = var.resource_schema
  }
}

resource "aws_api_gateway_integration_response" "http_200" {
  rest_api_id = var.api
  resource_id = var.resource
  http_method = aws_api_gateway_method.this.http_method
  status_code = aws_api_gateway_method_response.http_200.status_code

  response_templates = {
    "application/json" = file("${path.module}/../../../../schemas/response_crops_post.template")
  }

  depends_on = [aws_api_gateway_integration.this]
}
