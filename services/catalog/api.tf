
module "api" {
  source      = "../../modules/api"
  name        = "catalog_api"
  description = "The API for the catalog service"
}

resource "aws_api_gateway_resource" "producs" {
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "producs"
}

resource "aws_api_gateway_resource" "product" {
  rest_api_id = module.api.id
  parent_id   = aws_api_gateway_resource.producs.id
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
}