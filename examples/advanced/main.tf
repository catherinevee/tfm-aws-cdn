# Advanced example of CloudFront + S3 CDN module
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Random string for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket for CloudFront logs
resource "aws_s3_bucket" "logs" {
  bucket = "cloudfront-logs-${random_string.suffix.result}"

  tags = {
    Name        = "CloudFront Logs"
    Environment = "production"
    Project     = "example"
    Example     = "advanced"
  }
}

# S3 Bucket versioning for logs
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket server-side encryption for logs
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket lifecycle for logs
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "log_retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# Advanced CloudFront + S3 CDN
module "cdn_advanced" {
  source = "../../"

  bucket_name       = "my-static-assets-advanced-${random_string.suffix.result}"
  distribution_name = "my-cdn-distribution-advanced"

  # Custom cache behavior
  min_ttl     = 0
  default_ttl = 3600    # 1 hour
  max_ttl     = 86400   # 24 hours

  # Security
  enable_security_headers = true

  # Logging
  logging_config = {
    bucket          = aws_s3_bucket.logs.bucket
    include_cookies = true
    prefix          = "cloudfront-logs/"
  }

  # Custom error responses
  custom_error_responses = [
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    },
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]

  common_tags = {
    Environment = "production"
    Project     = "example"
    Example     = "advanced"
  }
}

# Example Lambda@Edge function (commented out - requires actual Lambda function)
# module "cdn_with_lambda" {
#   source = "../../"
#
#   bucket_name       = "my-static-assets-lambda-${random_string.suffix.result}"
#   distribution_name = "my-cdn-distribution-lambda"
#
#   lambda_function_associations = [
#     {
#       event_type   = "viewer-request"
#       lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:my-lambda-function:1"
#       include_body = false
#     }
#   ]
#
#   common_tags = {
#     Environment = "production"
#     Project     = "example"
#     Example     = "lambda"
#   }
# } 