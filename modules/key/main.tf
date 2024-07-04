data "aws_caller_identity" "this" {}

resource "aws_kms_key" "this" {
  description         = var.description
  enable_key_rotation = true
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "default"
    Statement = [
      {
        Sid    = "Enable root Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = var.role
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.us-east-1.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*"
      }
    ]
  })
}
