resource "aws_api_gateway_model" "Crop" {
  rest_api_id  = module.api.id
  name         = "Crop"
  description  = "Crop Json Schema"
  content_type = "application/json"
  schema       = file("${path.module}/../../schemas/crop.json")
}