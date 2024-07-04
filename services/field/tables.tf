
module "table_crops" {
  source  = "../../modules/table"
  name    = "crops"
  kms_key = var.key

  principals = [
    module.crop_add.lambda_role,
    module.crop_get.lambda_role,
    module.crop_plant.lambda_role,
    module.crop_harvest.lambda_role,
    module.crop_update.lambda_role,
  ]
}