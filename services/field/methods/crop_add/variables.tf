
variable "api" {
  type        = string
  description = "API Gateway ID"
}

variable "resource" {
  type        = string
  description = "resource of this method"
}

variable "validator" {
  type        = string
  description = "validator of this method"
}

variable "resource_schema" {
  type        = string
  description = "name of the resource schema"
}

variable "key" {
  type        = string
  description = "key for encryption"
}

variable "signer" {
  type        = string
  description = "code signer for the lambda function"
}

variable "global_layer" {
  type        = string
  description = "ARN of the global layer"
}
