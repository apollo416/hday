
module "catalog" {
  source       = "./services/catalog"
  key          = module.key.arn
  signer       = module.signer.config_arn
  global_layer = aws_lambda_layer_version.this.arn
}

module "field" {
  source             = "./services/field"
  key                = module.key.arn
  signer             = module.signer.config_arn
  global_layer       = aws_lambda_layer_version.this.arn
  catalog_invoke_url = module.catalog.invoke_url
}
