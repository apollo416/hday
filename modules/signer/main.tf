resource "aws_signer_signing_profile" "this" {
  platform_id = "AWSLambda-SHA384-ECDSA"

  signature_validity_period {
    value = 1
    type  = "MONTHS"
  }
}

resource "aws_lambda_code_signing_config" "this" {
  allowed_publishers {
    signing_profile_version_arns = [
      aws_signer_signing_profile.this.arn
    ]
  }

  policies {
    untrusted_artifact_on_deployment = "Warn"
  }

  description = "Lambda code signing configuration"
}