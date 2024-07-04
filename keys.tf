module "key" {
  source      = "./modules/key"
  description = "Environment key"
  role        = var.workspace_iam_role
}