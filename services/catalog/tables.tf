
module "table_products" {
  source  = "../../modules/table"
  name    = "products"
  kms_key = var.key

  principals = [
    module.catalog_init_lambda.role,
    module.product_get.lambda_role
  ]
}