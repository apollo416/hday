
module "api" {
  source      = "../../modules/api"
  name        = "field_api"
  description = "The API for the hday service"
}

resource "aws_api_gateway_resource" "crops" {
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "crops"
}

module "crops_post" {
  source          = "./methods/crops_post"
  api             = module.api.id
  resource        = aws_api_gateway_resource.crops.id
  validator       = module.api.validator
  resource_schema = aws_api_gateway_model.Crop.name
  key             = var.key
  signer          = var.signer
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
}

module "crop_update" {
  source          = "./methods/crop_update"
  api             = module.api.id
  resource        = aws_api_gateway_resource.crop.id
  validator       = module.api.validator
  resource_schema = aws_api_gateway_model.Crop.name
  key             = var.key
  signer          = var.signer
}