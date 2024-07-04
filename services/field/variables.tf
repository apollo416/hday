
variable "key" {
  type        = string
  description = "KMS key ARN to use for encryption"
}

variable "signer" {
  type        = string
  description = "signer for the lambda function"
}