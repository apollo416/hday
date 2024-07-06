
module "lambda" {
  source       = "../../../../modules/lambda"
  service      = "field"
  name         = "crop_add"
  key          = var.key
  signer       = var.signer
  api          = var.api
  global_layer = var.global_layer
}

resource "aws_api_gateway_method" "post" {
  # checkov:skip=CKV_AWS_59:Ensure there is no open access to backend resources through API
  rest_api_id   = var.api
  resource_id   = var.resource
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post" {
  rest_api_id             = var.api
  resource_id             = var.resource
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "http_201" {
  rest_api_id = var.api
  resource_id = var.resource
  http_method = aws_api_gateway_method.post.http_method
  status_code = "201"
  response_models = {
    "application/json" = var.resource_schema
  }
}

resource "aws_api_gateway_method" "get" {
  # checkov:skip=CKV_AWS_59:Ensure there is no open access to backend resources through API
  rest_api_id   = var.api
  resource_id   = var.resource
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id             = var.api
  resource_id             = var.resource
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "http_405" {
  rest_api_id = var.api
  resource_id = var.resource
  http_method = aws_api_gateway_method.get.http_method
  status_code = "405"
}
