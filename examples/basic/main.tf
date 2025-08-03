# Enhanced Basic example of CloudFront + S3 CDN module
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

# Enhanced CloudFront + S3 CDN
module "cdn_enhanced" {
  source = "../../"

  bucket_name       = "my-enhanced-static-assets-${random_string.suffix.result}"
  distribution_name = "my-enhanced-cdn-distribution"

  # Enhanced S3 Configuration
  s3_bucket_description = "Enhanced S3 bucket for static assets"
  s3_bucket_tags = {
    Environment = "development"
    Purpose     = "Static Assets"
  }
  enable_versioning = true
  s3_bucket_versioning_status = "Enabled"
  s3_bucket_encryption_algorithm = "AES256"
  s3_bucket_key_enabled = true
  s3_bucket_public_access_block = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  s3_bucket_lifecycle_rules = [
    {
      id     = "transition_to_ia"
      status = "Enabled"
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 365
      }
    }
  ]

  # Enhanced CloudFront Configuration
  enabled = true
  enable_ipv6 = true
  comment = "Enhanced CDN distribution for static assets"
  default_root_object = "index.html"
  http_version = "http2"
  retain_on_delete = false
  wait_for_deployment = true
  price_class = "PriceClass_100"
  aliases = ["cdn.example.com"]

  # Enhanced Origin Access Control
  origin_access_control_name = "enhanced-oac"
  origin_access_control_description = "Enhanced Origin Access Control"
  origin_access_control_origin_type = "s3"
  origin_access_control_signing_behavior = "always"
  origin_access_control_signing_protocol = "sigv4"

  # Enhanced Cache Behavior
  allowed_methods = ["GET", "HEAD", "OPTIONS"]
  cached_methods = ["GET", "HEAD"]
  forward_query_string = false
  forward_cookies = "none"
  forward_headers = []
  viewer_protocol_policy = "redirect-to-https"
  min_ttl = 0
  default_ttl = 86400
  max_ttl = 31536000
  enable_compression = true
  smooth_streaming = false
  trusted_signers = []
  trusted_key_groups = []

  # Enhanced Security
  enable_security_headers = true
  security_headers_function_name = "enhanced-security-headers"
  security_headers_function_comment = "Enhanced security headers function"
  security_headers_function_runtime = "cloudfront-js-1.0"
  web_acl_id = null
  web_acl_association_tags = {}

  # Enhanced Certificate Configuration
  viewer_certificate = {
    acm_certificate_arn = null
    ssl_support_method = null
    minimum_protocol_version = "TLSv1.2_2021"
    cloudfront_default_certificate = true
    iam_certificate_id = null
    certificate_source = "cloudfront"
  }

  # Enhanced Geo Restrictions
  geo_restrictions = {
    restriction_type = "none"
    locations = []
  }

  # Enhanced Logging Configuration
  logging_config = {
    bucket = "my-enhanced-logs-bucket-${random_string.suffix.result}"
    include_cookies = false
    prefix = "cdn-logs/"
  }
  logs_bucket_name = "my-enhanced-logs-bucket-${random_string.suffix.result}"
  logs_bucket_tags = {
    Environment = "development"
    Purpose     = "CDN Logs"
  }
  logs_bucket_versioning = "Enabled"
  logs_bucket_encryption_algorithm = "AES256"
  logs_bucket_lifecycle_rules = [
    {
      id     = "log_retention"
      status = "Enabled"
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 365
      }
    }
  ]

  # Enhanced Lambda@Edge Functions
  lambda_function_associations = []

  # Enhanced CloudFront Functions
  function_associations = []

  # Enhanced Custom Error Responses
  custom_error_responses = [
    {
      error_code = 404
      response_code = 200
      response_page_path = "/index.html"
      error_caching_min_ttl = 300
    }
  ]

  # Enhanced KMS Configuration
  enable_kms_encryption = false
  kms_key_description = "KMS key for CDN encryption"
  kms_key_deletion_window = 7
  kms_key_enable_rotation = true
  kms_key_policy = null
  kms_key_tags = {}

  # Enhanced Monitoring and Observability
  enable_cloudwatch_alarms = true
  cloudwatch_alarms = {
    high_error_rate = {
      alarm_description = "High error rate alarm"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 2
      metric_name = "5xxError"
      namespace = "AWS/CloudFront"
      period = 300
      statistic = "Sum"
      threshold = 10
      alarm_actions = []
      ok_actions = []
      insufficient_data_actions = []
      treat_missing_data = "missing"
      dimensions = {
        DistributionId = "dummy"
        Region = "Global"
      }
      tags = {}
    }
  }

  # Enhanced Cost Optimization
  enable_cost_optimization = true
  cost_optimization_config = {
    enable_auto_scaling = false
    enable_scheduled_actions = false
    enable_cost_allocation_tags = true
    enable_budget_alerts = true
    budget_amount = 100
    budget_currency = "USD"
  }

  # Enhanced Compliance and Governance
  enable_compliance_tagging = true
  compliance_tags = {
    Environment = "development"
    Project = "enhanced-cdn"
    Owner = "devops"
    DataClassification = "public"
    Compliance = "none"
  }
  enable_resource_policies = false
  resource_policies = {}

  # Enhanced Performance Features
  enable_field_level_encryption = false
  field_level_encryption_config = null
  enable_realtime_logs = false
  realtime_logs_config = null

  # Common Tags
  common_tags = {
    Environment = "development"
    Project     = "enhanced-cdn-example"
    Example     = "enhanced-basic"
    Version     = "2.0.0"
  }
}

# Random string for unique bucket name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
} 