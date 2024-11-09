resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "LambdaAndSNSFullAccess"
  description = "Policy to grant Lambda and SNS permissions along with existing EC2 and S3 access."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:*"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "SNS:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_lambda_sns_policy" {
  user       = "GitPod"
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}