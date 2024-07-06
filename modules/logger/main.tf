
resource "aws_kms_grant" "this" {
  count = var.role != null ? 1 : 0

  name              = "grant_${var.name}_loggroup"
  key_id            = var.key
  grantee_principal = var.role
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey", "Sign", "Verify"]
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${var.name}"
  # checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year
  retention_in_days = 7
  kms_key_id        = var.key

  depends_on = [aws_kms_grant.this]
}