
module "field" {
  source = "./services/field"
  key    = module.key.arn
  signer = module.signer.config_arn
}