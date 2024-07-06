resource "aws_lambda_layer_version" "this" {
  filename                 = "${path.root}/lambdas/layer/layer_content.zip"
  layer_name               = "global_layer"
  description              = "Global layer for all lambdas"
  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["arm64"]
  source_code_hash         = filebase64sha256("${path.root}/lambdas/layer/layer_content.zip")
}
