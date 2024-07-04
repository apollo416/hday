
output "arn" {
  value       = aws_lambda_function.this.arn
  description = "function arn"
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "role" {
  value = aws_iam_role.this.arn
}