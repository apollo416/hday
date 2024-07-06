
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

# resource "aws_lambda_invocation" "init_catalog" {
#   function_name = aws_lambda_function.lambda_function_test.function_name

#   input = jsonencode({
#     key1 = "value1"
#     key2 = "value2"
#   })
# }

# output "result_entry" {
#   value = jsondecode(aws_lambda_invocation.example.result)["key1"]
# }