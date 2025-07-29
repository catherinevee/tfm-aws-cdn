# Website hosting example with CloudFront + S3 CDN
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
  bucket = "website-logs-${random_string.suffix.result}"

  tags = {
    Name        = "Website CloudFront Logs"
    Environment = "production"
    Project     = "website"
    Example     = "website"
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

# Website CloudFront + S3 CDN
module "website_cdn" {
  source = "../../"

  bucket_name       = "my-website-assets-${random_string.suffix.result}"
  distribution_name = "my-website-cdn"

  # Website-specific settings
  default_root_object = "index.html"
  
  # Custom cache behavior optimized for websites
  min_ttl     = 0
  default_ttl = 1800    # 30 minutes for HTML files
  max_ttl     = 86400   # 24 hours for static assets

  # Security
  enable_security_headers = true

  # Logging
  logging_config = {
    bucket          = aws_s3_bucket.logs.bucket
    include_cookies = true
    prefix          = "website-logs/"
  }

  # Custom error responses for SPA routing
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

  # Example with custom domain (uncomment and configure)
  # aliases = ["www.example.com", "example.com"]
  
  # viewer_certificate = {
  #   acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  #   ssl_support_method       = "sni-only"
  #   minimum_protocol_version = "TLSv1.2_2021"
  # }

  common_tags = {
    Environment = "production"
    Project     = "website"
    Example     = "website"
  }
}

# Example: Upload sample website files
resource "aws_s3_object" "index_html" {
  bucket       = module.website_cdn.s3_bucket_id
  key          = "index.html"
  content      = file("${path.module}/files/index.html")
  content_type = "text/html"

  tags = {
    Name = "index.html"
  }
}

resource "aws_s3_object" "styles_css" {
  bucket       = module.website_cdn.s3_bucket_id
  key          = "styles.css"
  content      = file("${path.module}/files/styles.css")
  content_type = "text/css"

  tags = {
    Name = "styles.css"
  }
}

resource "aws_s3_object" "script_js" {
  bucket       = module.website_cdn.s3_bucket_id
  key          = "script.js"
  content      = file("${path.module}/files/script.js")
  content_type = "application/javascript"

  tags = {
    Name = "script.js"
  }
}

resource "aws_s3_object" "favicon_ico" {
  bucket       = module.website_cdn.s3_bucket_id
  key          = "favicon.ico"
  content      = file("${path.module}/files/favicon.ico")
  content_type = "image/x-icon"

  tags = {
    Name = "favicon.ico"
  }
} 