# Declare the variables in root module
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "tag_name" {
  description = "The tag name for the bucket"
  type        = string
}

variable "project_name" {
  description = "The name of the project associated with the bucket"
  type        = string
}

variable "version_flag" {
  description = "The versioning status of the S3 bucket"
  type        = string
}

variable "source_ip" {
  description = "The IP address that should be allowed access to the S3 bucket"
  type        = string
}

variable "lambda_sns_policy_attachment" {
  description = "Dependency on IAM policy attachment"
  type        = string
}
