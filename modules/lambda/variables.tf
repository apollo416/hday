
variable "service" {
  type        = string
  description = "Base service name"
}

variable "name" {
  type        = string
  description = "lambda name"
}

variable "key" {
  type        = string
  description = "KMS key ARN for the encryption of the log group"
}

variable "signer" {
  type        = string
  description = "Code signer for the lambda function"
}

variable "api" {
  type        = string
  description = "API Gateway ID"
}