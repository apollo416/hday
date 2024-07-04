
module "lambda" {
  source  = "../../../../modules/lambda"
  service = "field"
  name    = "crop_update"
  key     = var.key
  signer  = var.signer
  api     = var.api
}

resource "aws_api_gateway_method" "this" {
  # checkov:skip=CKV_AWS_59:Ensure there is no open access to backend resources through API
  rest_api_id   = var.api
  resource_id   = var.resource
  http_method   = "PUT"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }

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

  depends_on = [aws_api_gateway_integration.this]
}
