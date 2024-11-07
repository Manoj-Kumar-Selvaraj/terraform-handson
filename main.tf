module "s3_bucket" {
  source      = "./modules/s3"  # Path to your module
  bucket_name = var.bucket_name
  tag_name    = var.tag_name
  project_name = var.project_name
  version_flag = var.version_flag
}

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


# Optional: You can add backend configuration here if needed for state management
