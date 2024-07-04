
module "api" {
  source      = "../../modules/api"
  name        = "catalog_api"
  description = "The API for the catalog service"
}