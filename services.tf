
module "field" {
  source = "./services/field"
  key    = module.key.arn
  signer = module.signer.config_arn
}

module "catalog" {
  source = "./services/catalog"
  key    = module.key.arn
  signer = module.signer.config_arn
}
