# modules/s3/main.tf (Updated)
resource "aws_s3_bucket" "practice" {
  bucket = var.bucket_name

  tags = {
    Name    = var.tag_name
    Project = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "practice" {
  bucket = aws_s3_bucket.practice.id

  versioning_configuration {
    status = var.version_flag
  }
}

