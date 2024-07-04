resource "aws_dynamodb_table" "this" {
  # checkov:skip=CKV_AWS_28:Ensure DynamoDB point in time recovery (backup) is enabled
  # checkov:skip=CKV2_AWS_16:Ensure that Auto Scaling is enabled on your DynamoDB tables
  name                        = var.name
  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = false
  read_capacity               = 5
  write_capacity              = 5
  hash_key                    = "id"

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key
  }

  depends_on = [var.principals]
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]

    dynamic "principals" {
      for_each = var.principals
      iterator = principal

      content {
        type = "AWS"
        identifiers = [
          principal.value
        ]
      }
    }


    resources = [aws_dynamodb_table.this.arn]
  }
}

resource "aws_dynamodb_resource_policy" "this" {
  resource_arn = aws_dynamodb_table.this.arn
  policy       = data.aws_iam_policy_document.this.json
}