
module "api" {
  source      = "../../modules/api"
  name        = "catalog_api"
  description = "The API for the catalog service"
}

resource "aws_api_gateway_resource" "products" {
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "products"
}

resource "aws_api_gateway_resource" "product" {
  rest_api_id = module.api.id
  parent_id   = aws_api_gateway_resource.products.id
  path_part   = "{id}"
}

module "product_get" {
  source          = "./methods/product_get"
  api             = module.api.id
  resource        = aws_api_gateway_resource.product.id
  validator       = module.api.validator
  resource_schema = aws_api_gateway_model.Product.name
  key             = var.key
  signer          = var.signer
  global_layer    = var.global_layer
}


resource "aws_api_gateway_deployment" "this" {
  rest_api_id = module.api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  rest_api_id          = module.api.id
  deployment_id        = aws_api_gateway_deployment.this.id
  stage_name           = "main"
  xray_tracing_enabled = true
  depends_on           = [module.logger]

  access_log_settings {
    destination_arn = module.logger.arn
    format = jsonencode({
      "requestId" : "$context.requestId",
      "extendedRequestId" : "$context.extendedRequestId",
      "ip" : "$context.identity.sourceIp",
      "caller" : "$context.identity.caller",
      "user" : "$context.identity.user",
      "requestTime" : "$context.requestTime",
      "httpMethod" : "$context.httpMethod",
      "resourcePath" : "$context.resourcePath",
      "status" : "$context.status",
      "protocol" : "$context.protocol",
      "responseLength" : "$context.responseLength"
    })
  }
}

module "logger" {
  source = "../../modules/logger"
  name   = "${module.api.name}_access_logging"
  key    = var.key
}