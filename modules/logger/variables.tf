
variable "name" {
  type        = string
  description = "log group name"
}

variable "key" {
  type        = string
  description = "KMS key ARN for the encryption of the log group"
}

variable "role" {
  type        = string
  description = "IAM role ARN to allow"
  nullable    = true
  default     = null
}