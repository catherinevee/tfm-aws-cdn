# Basic example of CloudFront + S3 CDN module
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Basic CloudFront + S3 CDN
module "cdn_basic" {
  source = "../../"

  bucket_name       = "my-static-assets-bucket-${random_string.suffix.result}"
  distribution_name = "my-cdn-distribution-basic"

  common_tags = {
    Environment = "development"
    Project     = "example"
    Example     = "basic"
  }
}

# Random string for unique bucket name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
} 