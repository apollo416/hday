
resource "aws_api_gateway_model" "Product" {
  rest_api_id  = module.api.id
  name         = "Product"
  description  = "Product Json Schema"
  content_type = "application/json"
  schema       = file("${path.root}/schemas/product.json")
}
