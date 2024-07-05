resource "aws_lambda_function" "this" {
  # checkov:skip=CKV_AWS_117:Ensure that AWS Lambda function is configured inside a VPC
  function_name                  = var.name
  filename                       = data.archive_file.lambda.output_path
  source_code_hash               = data.archive_file.lambda.output_base64sha256
  role                           = aws_iam_role.this.arn
  runtime                        = "python3.12"
  handler                        = "${var.name}.handler"
  timeout                        = 10
  memory_size                    = 128
  architectures                  = ["arm64"]
  publish                        = true
  reserved_concurrent_executions = -1
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.lambda_cloudwatch_log_group.name
  }
  tracing_config {
    mode = "Active"
  }

  layers = [
    "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension-Arm64:20",
    "arn:aws:lambda:us-east-1:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:71"
  ]

  dead_letter_config {
    target_arn = aws_sqs_queue.this.arn
  }

  code_signing_config_arn = var.signer

  kms_key_arn = var.key

  environment {
    variables = {
      AWS_LAMBDA_LOG_LEVEL         = "INFO",
      POWERTOOLS_METRICS_NAMESPACE = "hday",
      POWERTOOLS_SERVICE_NAME      = var.service
    }
  }
}


resource "aws_iam_role" "this" {
  name               = "${var.name}_role"
  assume_role_policy = data.aws_iam_policy_document.role_policy_data.json
}

data "aws_iam_policy_document" "role_policy_data" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_kms_grant" "this" {
  name              = "grant_${var.name}_loggroup"
  key_id            = var.key
  grantee_principal = aws_iam_role.this.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey", "Sign", "Verify"]
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_log_group" {
  name = "/aws/lambda/${var.name}"
  # checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year
  retention_in_days = 7
  kms_key_id        = var.key

  depends_on = [aws_kms_grant.this]
}

resource "aws_sqs_queue" "this" {
  name                              = "${var.name}_dlq"
  kms_master_key_id                 = var.key
  kms_data_key_reuse_period_seconds = 300
}

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.root}/lambdas/${var.service}/${var.name}.zip"

  source {
    content  = file("${path.root}/lambdas/${var.service}/${var.name}.py")
    filename = "${var.name}.py"
  }

  dynamic "source" {
    for_each = var.include_files
    content {
      content  = file(source.value.content)
      filename = source.value.filename
    }
  }
}
resource "aws_iam_role_policy_attachment" "basic_execution_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "insights_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "xray_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_permission" "allow_api" {
  # checkov:skip=CKV_AWS_364:Ensure that AWS Lambda function permissions delegated to AWS services are limited by SourceArn or SourceAccount
  statement_id  = "AllowExecutionFromAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  #source_arn    = var.api
  depends_on = [aws_lambda_function.this]
}