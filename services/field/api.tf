
module "api" {
  source      = "../../modules/api"
  name        = "field_api"
  description = "The API for the field service"
}

resource "aws_api_gateway_resource" "crops" {
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "crops"
}

module "crop_add" {
  source           = "./methods/crop_add"
  api              = module.api.id
  resource         = aws_api_gateway_resource.crops.id
  validator        = module.api.validator
  resource_schema  = aws_api_gateway_model.Crop.name
  key              = var.key
  signer           = var.signer
  global_layer     = var.global_layer
  catalog_base_url = var.catalog_invoke_url
}

resource "aws_api_gateway_resource" "crop" {
  rest_api_id = module.api.id
  parent_id   = aws_api_gateway_resource.crops.id
  path_part   = "{id}"
}

module "crop_get" {
  source          = "./methods/crop_get"
  api             = module.api.id
  resource        = aws_api_gateway_resource.crop.id
  validator       = module.api.validator
  resource_schema = aws_api_gateway_model.Crop.name
  key             = var.key
  signer          = var.signer
  global_layer    = var.global_layer
}

resource "aws_api_gateway_resource" "plant" {
  rest_api_id = module.api.id
  parent_id   = aws_api_gateway_resource.crop.id
  path_part   = "plant"
}

module "crop_plant" {
  source          = "./methods/crop_plant"
  api             = module.api.id
  resource        = aws_api_gateway_resource.plant.id
  validator       = module.api.validator
  resource_schema = aws_api_gateway_model.Crop.name
  key             = var.key
  signer          = var.signer
  global_layer    = var.global_layer
}

resource "aws_api_gateway_resource" "harvest" {
  rest_api_id = module.api.id
  parent_id   = aws_api_gateway_resource.crop.id
  path_part   = "harvest"
}

module "crop_harvest" {
  source          = "./methods/crop_harvest"
  api             = module.api.id
  resource        = aws_api_gateway_resource.harvest.id
  validator       = module.api.validator
  resource_schema = aws_api_gateway_model.Crop.name
  key             = var.key
  signer          = var.signer
  global_layer    = var.global_layer
}

module "crop_update" {
  source          = "./methods/crop_update"
  api             = module.api.id
  resource        = aws_api_gateway_resource.crop.id
  validator       = module.api.validator
  resource_schema = aws_api_gateway_model.Crop.name
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