
variable "name" {
  type        = string
  description = "dynamodb table name"
}

variable "kms_key" {
  type        = string
  description = "KMS key ARN for the encryption of the dynamodb table"
}

variable "principals" {
  type        = list(string)
  description = "List of IAM roles that can access the dynamodb table"
}