# Test configuration for CloudFront + S3 CDN module
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

# Test CloudFront + S3 CDN
module "test_cdn" {
  source = "../"

  bucket_name       = "test-cdn-bucket-${random_string.suffix.result}"
  distribution_name = "test-cdn-distribution"

  # Test with minimal configuration
  enabled = true
  comment = "Test CDN distribution"

  common_tags = {
    Environment = "test"
    Project     = "test"
    Purpose     = "testing"
  }
} 