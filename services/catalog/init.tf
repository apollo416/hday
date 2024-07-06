
module "catalog_init_lambda" {
  source  = "../../modules/lambda"
  service = "catalog"
  name    = "catalog_init"
  key     = var.key
  signer  = var.signer
  api     = module.api.id
  include_files = [
    {
      content  = "${path.root}/data/crops.json"
      filename = "crops.json"
    }
  ]
  global_layer = var.global_layer
}
