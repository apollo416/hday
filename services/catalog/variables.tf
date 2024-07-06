
variable "key" {
  type        = string
  description = "KMS key ARN to use for encryption"
}

variable "signer" {
  type        = string
  description = "signer for the lambda function"
}

variable "global_layer" {
  type        = string
  description = "ARN of the global layer"
}