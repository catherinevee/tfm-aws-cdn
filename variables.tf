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

# Optional Variables with Defaults
variable "enabled" {
  description = "Whether the CloudFront distribution is enabled"
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  description = "Whether to enable IPv6 support"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
  default     = "CDN distribution for static assets"
}

variable "default_root_object" {
  description = "Default root object for the CloudFront distribution"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
  
  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "Price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

variable "aliases" {
  description = "List of aliases for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "enable_versioning" {
  description = "Whether to enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

# Cache Behavior Variables
variable "allowed_methods" {
  description = "Allowed HTTP methods for the cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
  
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
  default     = ["GET", "HEAD"]
  
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
  default     = false
}

variable "forward_cookies" {
  description = "How to forward cookies to the origin"
  type        = string
  default     = "none"
  
  validation {
    condition     = contains(["none", "all", "whitelist"], var.forward_cookies)
    error_message = "Forward cookies must be one of: none, all, whitelist."
  }
}

variable "viewer_protocol_policy" {
  description = "Viewer protocol policy for the cache behavior"
  type        = string
  default     = "redirect-to-https"
  
  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.viewer_protocol_policy)
    error_message = "Viewer protocol policy must be one of: allow-all, https-only, redirect-to-https."
  }
}

variable "min_ttl" {
  description = "Minimum TTL for cached objects"
  type        = number
  default     = 0
  
  validation {
    condition     = var.min_ttl >= 0
    error_message = "Minimum TTL must be 0 or greater."
  }
}

variable "default_ttl" {
  description = "Default TTL for cached objects"
  type        = number
  default     = 86400
  
  validation {
    condition     = var.default_ttl >= 0
    error_message = "Default TTL must be 0 or greater."
  }
}

variable "max_ttl" {
  description = "Maximum TTL for cached objects"
  type        = number
  default     = 31536000
  
  validation {
    condition     = var.max_ttl >= 0
    error_message = "Maximum TTL must be 0 or greater."
  }
}

variable "enable_compression" {
  description = "Whether to enable compression for the cache behavior"
  type        = bool
  default     = true
}

# Security Variables
variable "enable_security_headers" {
  description = "Whether to enable security headers via CloudFront Function"
  type        = bool
  default     = true
}

variable "web_acl_id" {
  description = "Web ACL ID to associate with the CloudFront distribution"
  type        = string
  default     = null
}

# Certificate and Domain Variables
variable "viewer_certificate" {
  description = "Viewer certificate configuration"
  type = object({
    acm_certificate_arn            = optional(string)
    ssl_support_method             = optional(string)
    minimum_protocol_version       = optional(string)
    cloudfront_default_certificate = optional(bool)
    iam_certificate_id             = optional(string)
  })
  default = null
}

# Geo Restrictions
variable "geo_restrictions" {
  description = "Geo restrictions configuration"
  type = object({
    restriction_type = string
    locations        = optional(list(string))
  })
  default = null
  
  validation {
    condition = var.geo_restrictions == null || contains(["whitelist", "blacklist"], var.geo_restrictions.restriction_type)
    error_message = "Restriction type must be either 'whitelist' or 'blacklist'."
  }
}

# Logging Configuration
variable "logging_config" {
  description = "Logging configuration for CloudFront"
  type = object({
    bucket          = string
    include_cookies = optional(bool, false)
    prefix          = optional(string)
  })
  default = null
}

# Lambda@Edge Functions
variable "lambda_function_associations" {
  description = "Lambda@Edge function associations"
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = optional(bool, false)
  }))
  default = []
  
  validation {
    condition = alltrue([
      for assoc in var.lambda_function_associations : contains([
        "viewer-request", "viewer-response", "origin-request", "origin-response"
      ], assoc.event_type)
    ])
    error_message = "Event type must be one of: viewer-request, viewer-response, origin-request, origin-response."
  }
}

# CloudFront Functions
variable "function_associations" {
  description = "CloudFront function associations"
  type = list(object({
    event_type   = string
    function_arn = string
  }))
  default = []
  
  validation {
    condition = alltrue([
      for assoc in var.function_associations : contains([
        "viewer-request", "viewer-response"
      ], assoc.event_type)
    ])
    error_message = "Event type must be one of: viewer-request, viewer-response."
  }
}

# Custom Error Responses
variable "custom_error_responses" {
  description = "Custom error responses"
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

# Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for key, value in var.common_tags : length(key) <= 128 && length(value) <= 256
    ])
    error_message = "Tag keys must be 128 characters or less, and tag values must be 256 characters or less."
  }
} 