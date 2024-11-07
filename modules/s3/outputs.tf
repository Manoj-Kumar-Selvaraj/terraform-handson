# modules/s3/outputs.tf (Optional)
output "bucket_id" {
  value = aws_s3_bucket.practice.id
}

output "bucket_arn" {
  value = aws_s3_bucket.practice.arn
}
