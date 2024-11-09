output "lambda_sns_policy_attachment" {
  value = aws_iam_policy.lambda_sns_policy.arn
}
