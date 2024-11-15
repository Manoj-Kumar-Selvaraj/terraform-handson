# Main S3 Bucket Resource
resource "aws_s3_bucket" "practice" {
  bucket = var.bucket_name
  /*
  
  In AWS S3, acceleration_status refers to S3 Transfer Acceleration, 
  a feature that enables faster data transfers to and from Amazon S3 buckets by using optimized network paths and Amazon CloudFront’s globally distributed edge locations. 
  When you enable transfer acceleration for a bucket, data transfers can benefit from lower latency and higher throughput.
  
  */
  # acceleration_status = "Suspended" 
  tags = {
    Name    = var.tag_name
    Project = var.project_name
  }

  # Optional: Add default Object Lock configuration
  object_lock_configuration {
    object_lock_enabled = "Enabled"  # This is mandatory to use Object Lock features

    rule {
      default_retention {
        mode = "GOVERNANCE"          # Set to "GOVERNANCE" for modifiable object retention or "COMPLIANCE" for immutable retention
        days = 30                    # Number of days for default retention
      }
    }
  }
  server_side_encryption_configuration {
    
     rule { 
        apply_server_side_encryption_by_default { 

            sse_algorithm = "AES256" 

            }
        } 
    }
}

# Versioning Configuration for the S3 Bucket
resource "aws_s3_bucket_versioning" "practice" {
  bucket = aws_s3_bucket.practice.id

  versioning_configuration {
    status = var.version_flag
  }
}

# Bucket policy to allow access from a specific IP for a specific IAM user
resource "aws_s3_bucket_policy" "practice_policy" {
  bucket = aws_s3_bucket.practice.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAccessFromSpecificIPForUser"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.practice.bucket}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.source_ip
          }
        }
      }
    ]
  })
}

# Lifecycle rule to transition and expire objects
/*
CORS is necessary when you want your resources (such as images, videos, or scripts) 
to be accessible from a different domain than your S3 bucket.
*/



# S3 Bucket Notification for Event Triggering
/*
In AWS S3, you can configure event notifications to trigger Lambda functions,
SQS queues, or SNS topics based on certain events (like object creation, deletion, or specific object uploads).
*/

# SNS Topic for S3 Event Notifications
resource "aws_sns_topic" "s3_event_notifications" {
   depends_on = [var.lambda_sns_policy_attachment]   # Ensures SNS is initiated after policy attachment
  name = "s3-event-notifications"
}

# Allow S3 to publish to the SNS topic
resource "aws_sns_topic_policy" "sns_policy" {
  arn = aws_sns_topic.s3_event_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "SNS:Publish"
        Resource = aws_sns_topic.s3_event_notifications.arn
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "s3_event_notification_practice" {
  bucket = aws_s3_bucket.practice.bucket
  depends_on = [aws_sns_topic.s3_event_notifications]
  # Configure notifications for specific events (object creation, deletion, and restore)
  topic {
    topic_arn = aws_sns_topic.s3_event_notifications.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*", "s3:ObjectRestore:*"]
  }
}

# Subscribing to the SNS Topic:
# Step 1: Subscribe an Email to the SNS Topic
# Add the aws_sns_topic_subscription resource in your Terraform code for the email subscription.

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.s3_event_notifications.arn
  protocol  = "email"
  endpoint  = "ss.mano1998@gmail.com"
}

