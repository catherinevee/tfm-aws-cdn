# Required Variables
variable "bucket_name" {
  description = "Name of the S3 bucket for static assets"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be between 3 and 63 characters, contain only lowercase letters, numbers, hyphens, and periods, and start and end with a letter or number."
  }
}

variable "distribution_name" {
  description = "Name for the CloudFront distribution"
  type        = string

  validation {
    condition     = length(var.distribution_name) >= 1 && length(var.distribution_name) <= 128
    error_message = "Distribution name must be between 1 and 128 characters."
  }
}

# Enhanced S3 Configuration
variable "s3_bucket_description" {
  description = "Description for the S3 bucket"
  type        = string
  default     = "S3 bucket for static assets" # Default: "S3 bucket for static assets"
}

variable "s3_bucket_tags" {
  description = "Additional tags for the S3 bucket"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "enable_versioning" {
  description = "Whether to enable versioning on the S3 bucket"
  type        = bool
  default     = true # Default: true
}

variable "s3_bucket_versioning_status" {
  description = "Versioning status for the S3 bucket"
  type        = string
  default     = "Enabled" # Default: "Enabled"

  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.s3_bucket_versioning_status)
    error_message = "Versioning status must be one of: Enabled, Suspended, Disabled."
  }
}

variable "s3_bucket_encryption_algorithm" {
  description = "Server-side encryption algorithm for the S3 bucket"
  type        = string
  default     = "AES256" # Default: "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.s3_bucket_encryption_algorithm)
    error_message = "Encryption algorithm must be one of: AES256, aws:kms."
  }
}

variable "s3_bucket_kms_key_id" {
  description = "KMS key ID for S3 bucket encryption (required if encryption_algorithm is aws:kms)"
  type        = string
  default     = null # Default: null
}

variable "s3_bucket_key_enabled" {
  description = "Whether to enable bucket key for S3 bucket"
  type        = bool
  default     = true # Default: true
}

variable "s3_bucket_public_access_block" {
  description = "Public access block configuration for S3 bucket"
  type = object({
    block_public_acls       = optional(bool, true) # Default: true
    block_public_policy     = optional(bool, true) # Default: true
    ignore_public_acls      = optional(bool, true) # Default: true
    restrict_public_buckets = optional(bool, true) # Default: true
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "s3_bucket_lifecycle_rules" {
  description = "Lifecycle rules for the S3 bucket"
  type = list(object({
    id      = string
    status  = string
    enabled = optional(bool, true) # Default: true
    transition = optional(list(object({
      days          = number
      storage_class = string
    })), []) # Default: empty list
    expiration = optional(object({
      days = optional(number, null) # Default: null
      expired_object_delete_marker = optional(bool, null) # Default: null
    }), null) # Default: null
    noncurrent_version_transition = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })), []) # Default: empty list
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }), null) # Default: null
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }), null) # Default: null
  }))
  default = [] # Default: empty list
}

variable "s3_bucket_policy" {
  description = "Custom S3 bucket policy (if null, default CloudFront policy is used)"
  type        = string
  default     = null # Default: null (default CloudFront policy)
}

# Enhanced CloudFront Configuration
variable "enabled" {
  description = "Whether the CloudFront distribution is enabled"
  type        = bool
  default     = true # Default: true
}

variable "enable_ipv6" {
  description = "Whether to enable IPv6 support"
  type        = bool
  default     = true # Default: true
}

variable "comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
  default     = "CDN distribution for static assets" # Default: "CDN distribution for static assets"
}

variable "default_root_object" {
  description = "Default root object for the CloudFront distribution"
  type        = string
  default     = "index.html" # Default: "index.html"
}

variable "http_version" {
  description = "HTTP version for the CloudFront distribution"
  type        = string
  default     = "http2" # Default: "http2"

  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.http_version)
    error_message = "HTTP version must be one of: http1.1, http2, http2and3, http3."
  }
}

variable "retain_on_delete" {
  description = "Whether to retain the CloudFront distribution when deleted"
  type        = bool
  default     = false # Default: false
}

variable "wait_for_deployment" {
  description = "Whether to wait for the CloudFront distribution to be deployed"
  type        = bool
  default     = true # Default: true
}

variable "price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_100" # Default: "PriceClass_100"
  
  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "Price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

variable "aliases" {
  description = "List of aliases for the CloudFront distribution"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "origin_access_control_name" {
  description = "Name for the CloudFront Origin Access Control"
  type        = string
  default     = null # Default: null (auto-generated)
}

variable "origin_access_control_description" {
  description = "Description for the CloudFront Origin Access Control"
  type        = string
  default     = null # Default: null (auto-generated)
}

variable "origin_access_control_origin_type" {
  description = "Origin type for the CloudFront Origin Access Control"
  type        = string
  default     = "s3" # Default: "s3"

  validation {
    condition     = contains(["s3", "mediastore"], var.origin_access_control_origin_type)
    error_message = "Origin type must be one of: s3, mediastore."
  }
}

variable "origin_access_control_signing_behavior" {
  description = "Signing behavior for the CloudFront Origin Access Control"
  type        = string
  default     = "always" # Default: "always"

  validation {
    condition     = contains(["always", "never", "no-override"], var.origin_access_control_signing_behavior)
    error_message = "Signing behavior must be one of: always, never, no-override."
  }
}

variable "origin_access_control_signing_protocol" {
  description = "Signing protocol for the CloudFront Origin Access Control"
  type        = string
  default     = "sigv4" # Default: "sigv4"

  validation {
    condition     = contains(["sigv4"], var.origin_access_control_signing_protocol)
    error_message = "Signing protocol must be sigv4."
  }
}

# Enhanced Cache Behavior Variables
variable "allowed_methods" {
  description = "Allowed HTTP methods for the cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"] # Default: ["GET", "HEAD", "OPTIONS"]
  
  validation {
    condition = alltrue([
      for method in var.allowed_methods : contains(["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"], method)
    ])
    error_message = "Allowed methods must be valid HTTP methods."
  }
}

variable "cached_methods" {
  description = "Cached HTTP methods for the cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD"] # Default: ["GET", "HEAD"]
  
  validation {
    condition = alltrue([
      for method in var.cached_methods : contains(["GET", "HEAD", "OPTIONS"], method)
    ])
    error_message = "Cached methods must be GET, HEAD, or OPTIONS."
  }
}

variable "forward_query_string" {
  description = "Whether to forward query strings to the origin"
  type        = bool
  default     = false # Default: false
}

variable "forward_cookies" {
  description = "How to forward cookies to the origin"
  type        = string
  default     = "none" # Default: "none"
  
  validation {
    condition     = contains(["none", "all", "whitelist"], var.forward_cookies)
    error_message = "Forward cookies must be one of: none, all, whitelist."
  }
}

variable "forward_cookies_whitelist" {
  description = "List of cookies to forward when forward_cookies is whitelist"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "forward_headers" {
  description = "List of headers to forward to the origin"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "viewer_protocol_policy" {
  description = "Viewer protocol policy for the cache behavior"
  type        = string
  default     = "redirect-to-https" # Default: "redirect-to-https"
  
  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.viewer_protocol_policy)
    error_message = "Viewer protocol policy must be one of: allow-all, https-only, redirect-to-https."
  }
}

variable "min_ttl" {
  description = "Minimum TTL for cached objects"
  type        = number
  default     = 0 # Default: 0
  
  validation {
    condition     = var.min_ttl >= 0
    error_message = "Minimum TTL must be 0 or greater."
  }
}

variable "default_ttl" {
  description = "Default TTL for cached objects"
  type        = number
  default     = 86400 # Default: 86400 (24 hours)
  
  validation {
    condition     = var.default_ttl >= 0
    error_message = "Default TTL must be 0 or greater."
  }
}

variable "max_ttl" {
  description = "Maximum TTL for cached objects"
  type        = number
  default     = 31536000 # Default: 31536000 (1 year)
  
  validation {
    condition     = var.max_ttl >= 0
    error_message = "Maximum TTL must be 0 or greater."
  }
}

variable "enable_compression" {
  description = "Whether to enable compression for the cache behavior"
  type        = bool
  default     = true # Default: true
}

variable "smooth_streaming" {
  description = "Whether to enable smooth streaming for the cache behavior"
  type        = bool
  default     = false # Default: false
}

variable "trusted_signers" {
  description = "List of trusted signers for the cache behavior"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "trusted_key_groups" {
  description = "List of trusted key groups for the cache behavior"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "realtime_log_config_arn" {
  description = "ARN of the real-time log configuration for the cache behavior"
  type        = string
  default     = null # Default: null
}

variable "response_headers_policy_id" {
  description = "ID of the response headers policy for the cache behavior"
  type        = string
  default     = null # Default: null
}

# Enhanced Security Variables
variable "enable_security_headers" {
  description = "Whether to enable security headers via CloudFront Function"
  type        = bool
  default     = true # Default: true
}

variable "security_headers_function_name" {
  description = "Name for the security headers CloudFront function"
  type        = string
  default     = null # Default: null (auto-generated)
}

variable "security_headers_function_comment" {
  description = "Comment for the security headers CloudFront function"
  type        = string
  default     = null # Default: null (auto-generated)
}

variable "security_headers_function_runtime" {
  description = "Runtime for the security headers CloudFront function"
  type        = string
  default     = "cloudfront-js-1.0" # Default: "cloudfront-js-1.0"

  validation {
    condition     = contains(["cloudfront-js-1.0"], var.security_headers_function_runtime)
    error_message = "Runtime must be cloudfront-js-1.0."
  }
}

variable "security_headers_function_code" {
  description = "Custom code for the security headers CloudFront function (if null, default code is used)"
  type        = string
  default     = null # Default: null (default code)
}

variable "web_acl_id" {
  description = "Web ACL ID to associate with the CloudFront distribution"
  type        = string
  default     = null # Default: null
}

variable "web_acl_association_tags" {
  description = "Additional tags for Web ACL association"
  type        = map(string)
  default     = {} # Default: empty map
}

# Enhanced Certificate and Domain Variables
variable "viewer_certificate" {
  description = "Viewer certificate configuration"
  type = object({
    acm_certificate_arn            = optional(string, null) # Default: null
    ssl_support_method             = optional(string, null) # Default: null
    minimum_protocol_version       = optional(string, "TLSv1.2_2021") # Default: "TLSv1.2_2021"
    cloudfront_default_certificate = optional(bool, null) # Default: null
    iam_certificate_id             = optional(string, null) # Default: null
    certificate_source             = optional(string, "cloudfront") # Default: "cloudfront"
  })
  default = null # Default: null
}

# Enhanced Geo Restrictions
variable "geo_restrictions" {
  description = "Geo restrictions configuration"
  type = object({
    restriction_type = string
    locations        = optional(list(string), []) # Default: empty list
  })
  default = null # Default: null
  
  validation {
    condition = var.geo_restrictions == null || contains(["whitelist", "blacklist"], var.geo_restrictions.restriction_type)
    error_message = "Restriction type must be either 'whitelist' or 'blacklist'."
  }
}

# Enhanced Logging Configuration
variable "logging_config" {
  description = "Logging configuration for CloudFront"
  type = object({
    bucket          = string
    include_cookies = optional(bool, false) # Default: false
    prefix          = optional(string, null) # Default: null
  })
  default = null # Default: null
}

variable "logs_bucket_name" {
  description = "Custom name for the logs S3 bucket (if null, auto-generated)"
  type        = string
  default     = null # Default: null (auto-generated)
}

variable "logs_bucket_tags" {
  description = "Additional tags for the logs S3 bucket"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "logs_bucket_versioning" {
  description = "Versioning status for the logs S3 bucket"
  type        = string
  default     = "Enabled" # Default: "Enabled"

  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.logs_bucket_versioning)
    error_message = "Logs bucket versioning must be one of: Enabled, Suspended, Disabled."
  }
}

variable "logs_bucket_encryption_algorithm" {
  description = "Server-side encryption algorithm for the logs S3 bucket"
  type        = string
  default     = "AES256" # Default: "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.logs_bucket_encryption_algorithm)
    error_message = "Logs bucket encryption algorithm must be one of: AES256, aws:kms."
  }
}

variable "logs_bucket_kms_key_id" {
  description = "KMS key ID for logs S3 bucket encryption"
  type        = string
  default     = null # Default: null
}

variable "logs_bucket_lifecycle_rules" {
  description = "Lifecycle rules for the logs S3 bucket"
  type = list(object({
    id      = string
    status  = string
    enabled = optional(bool, true) # Default: true
    transition = optional(list(object({
      days          = number
      storage_class = string
    })), []) # Default: empty list
    expiration = optional(object({
      days = optional(number, null) # Default: null
      expired_object_delete_marker = optional(bool, null) # Default: null
    }), null) # Default: null
    noncurrent_version_transition = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })), []) # Default: empty list
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }), null) # Default: null
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }), null) # Default: null
  }))
  default = [
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
  ] # Default: standard log retention rule
}

# Enhanced Lambda@Edge Functions
variable "lambda_function_associations" {
  description = "Lambda@Edge function associations"
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = optional(bool, false) # Default: false
  }))
  default = [] # Default: empty list
  
  validation {
    condition = alltrue([
      for assoc in var.lambda_function_associations : contains([
        "viewer-request", "viewer-response", "origin-request", "origin-response"
      ], assoc.event_type)
    ])
    error_message = "Event type must be one of: viewer-request, viewer-response, origin-request, origin-response."
  }
}

# Enhanced CloudFront Functions
variable "function_associations" {
  description = "CloudFront function associations"
  type = list(object({
    event_type   = string
    function_arn = string
  }))
  default = [] # Default: empty list
  
  validation {
    condition = alltrue([
      for assoc in var.function_associations : contains([
        "viewer-request", "viewer-response"
      ], assoc.event_type)
    ])
    error_message = "Event type must be one of: viewer-request, viewer-response."
  }
}

# Enhanced Custom Error Responses
variable "custom_error_responses" {
  description = "Custom error responses"
  type = list(object({
    error_code            = number
    response_code         = optional(number, null) # Default: null
    response_page_path    = optional(string, null) # Default: null
    error_caching_min_ttl = optional(number, null) # Default: null
  }))
  default = [] # Default: empty list
}

# Enhanced Origin Configuration
variable "origin_config" {
  description = "Enhanced origin configuration"
  type = object({
    domain_name = optional(string, null) # Default: null (uses S3 bucket)
    origin_id   = optional(string, null) # Default: null (auto-generated)
    origin_path = optional(string, null) # Default: null
    origin_access_control_id = optional(string, null) # Default: null (auto-generated)
    origin_shield = optional(object({
      enabled              = bool
      origin_shield_region = string
    }), null) # Default: null
    custom_origin_config = optional(object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_read_timeout      = optional(number, 30) # Default: 30
      origin_keepalive_timeout = optional(number, 5) # Default: 5
    }), null) # Default: null
    custom_header = optional(list(object({
      name  = string
      value = string
    })), []) # Default: empty list
  })
  default = null # Default: null (uses default S3 origin)
}

# Enhanced Performance Configuration
variable "enable_field_level_encryption" {
  description = "Whether to enable field-level encryption"
  type        = bool
  default     = false # Default: false
}

variable "field_level_encryption_config" {
  description = "Field-level encryption configuration"
  type = object({
    query_arg_profile_config = optional(object({
      forward_when_query_arg_profile_is_unknown = bool
      query_arg_profiles = optional(object({
        quantity = number
        items = optional(list(object({
          profile_id = string
          query_arg = string
        })), []) # Default: empty list
      }), null) # Default: null
    }), null) # Default: null
    content_type_profile_config = optional(object({
      forward_when_content_type_is_unknown = bool
      content_type_profiles = optional(object({
        quantity = number
        items = optional(list(object({
          profile_id = string
          content_type = string
          format = string
        })), []) # Default: empty list
      }), null) # Default: null
    }), null) # Default: null
  })
  default = null # Default: null
}

variable "enable_realtime_logs" {
  description = "Whether to enable real-time logs"
  type        = bool
  default     = false # Default: false
}

variable "realtime_logs_config" {
  description = "Real-time logs configuration"
  type = object({
    name = string
    sampling_rate = number
    fields = list(string)
    end_points = list(object({
      stream_type = string
      kinesis_stream_config = object({
        role_arn = string
        stream_arn = string
      })
    }))
  })
  default = null # Default: null
}

# Enhanced Monitoring and Observability
variable "enable_cloudwatch_alarms" {
  description = "Whether to enable CloudWatch alarms for the distribution"
  type        = bool
  default     = false # Default: false
}

variable "cloudwatch_alarms" {
  description = "CloudWatch alarms configuration"
  type = map(object({
    alarm_description = optional(string, "CloudFront distribution alarm") # Default: "CloudFront distribution alarm"
    comparison_operator = string
    evaluation_periods = optional(number, 2) # Default: 2
    metric_name = string
    namespace = string
    period = optional(number, 300) # Default: 300
    statistic = optional(string, "Sum") # Default: "Sum"
    threshold = number
    alarm_actions = optional(list(string), []) # Default: empty list
    ok_actions = optional(list(string), []) # Default: empty list
    insufficient_data_actions = optional(list(string), []) # Default: empty list
    treat_missing_data = optional(string, "missing") # Default: "missing"
    unit = optional(string, null) # Default: null
    extended_statistic = optional(string, null) # Default: null
    datapoints_to_alarm = optional(number, null) # Default: null
    threshold_metric_id = optional(string, null) # Default: null
    dimensions = optional(map(string), {}) # Default: empty map
    tags = optional(map(string), {}) # Default: empty map
  }))
  default = {} # Default: empty map
}

# Enhanced Compliance and Governance
variable "enable_compliance_tagging" {
  description = "Whether to enable compliance tagging"
  type        = bool
  default     = false # Default: false
}

variable "compliance_tags" {
  description = "Compliance tags to apply to all resources"
  type = object({
    Environment = optional(string, "dev") # Default: "dev"
    Project     = optional(string, "cdn") # Default: "cdn"
    Owner       = optional(string, "devops") # Default: "devops"
    DataClassification = optional(string, "public") # Default: "public"
    Compliance = optional(string, "none") # Default: "none"
  })
  default = {
    Environment = "dev"
    Project = "cdn"
    Owner = "devops"
    DataClassification = "public"
    Compliance = "none"
  }
}

variable "enable_resource_policies" {
  description = "Whether to enable resource policies"
  type        = bool
  default     = false # Default: false
}

variable "resource_policies" {
  description = "Resource policies configuration"
  type = map(object({
    policy_type = string
    policy_document = string
  }))
  default = {} # Default: empty map
}

# Enhanced KMS Configuration
variable "enable_kms_encryption" {
  description = "Whether to enable KMS encryption for S3 buckets"
  type        = bool
  default     = false # Default: false
}

variable "kms_key_description" {
  description = "Description for KMS key"
  type        = string
  default     = "KMS key for CDN encryption" # Default: "KMS key for CDN encryption"
}

variable "kms_key_deletion_window" {
  description = "Deletion window in days for KMS key"
  type        = number
  default     = 7 # Default: 7 days

  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "kms_key_enable_rotation" {
  description = "Enable automatic key rotation for KMS key"
  type        = bool
  default     = true # Default: true
}

variable "kms_key_policy" {
  description = "Custom KMS key policy (if null, default policy is used)"
  type        = string
  default     = null # Default: null (default policy)
}

variable "kms_key_tags" {
  description = "Additional tags for KMS key"
  type        = map(string)
  default     = {} # Default: empty map
}

# Enhanced Cost Optimization
variable "enable_cost_optimization" {
  description = "Whether to enable cost optimization features"
  type        = bool
  default     = false # Default: false
}

variable "cost_optimization_config" {
  description = "Cost optimization configuration"
  type = object({
    enable_auto_scaling = optional(bool, false) # Default: false
    enable_scheduled_actions = optional(bool, false) # Default: false
    enable_cost_allocation_tags = optional(bool, true) # Default: true
    enable_budget_alerts = optional(bool, false) # Default: false
    budget_amount = optional(number, 100) # Default: 100
    budget_currency = optional(string, "USD") # Default: "USD"
  })
  default = {
    enable_auto_scaling = false
    enable_scheduled_actions = false
    enable_cost_allocation_tags = true
    enable_budget_alerts = false
    budget_amount = 100
    budget_currency = "USD"
  }
}

# Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {} # Default: empty map
  
  validation {
    condition = alltrue([
      for key, value in var.common_tags : length(key) <= 128 && length(value) <= 256
    ])
    error_message = "Tag keys must be 128 characters or less, and tag values must be 256 characters or less."
  }
} 