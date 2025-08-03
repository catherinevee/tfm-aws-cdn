# Enhanced S3 Bucket Outputs
output "s3_bucket_id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.static_assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.static_assets.arn
}

output "s3_bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.static_assets.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = aws_s3_bucket.static_assets.bucket_regional_domain_name
}

output "s3_bucket_versioning_status" {
  description = "The versioning status of the S3 bucket"
  value       = aws_s3_bucket_versioning.static_assets.versioning_configuration[0].status
}

output "s3_bucket_encryption_algorithm" {
  description = "The encryption algorithm used for the S3 bucket"
  value       = aws_s3_bucket_server_side_encryption_configuration.static_assets.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm
}

output "s3_bucket_kms_key_id" {
  description = "The KMS key ID used for S3 bucket encryption (if applicable)"
  value       = aws_s3_bucket_server_side_encryption_configuration.static_assets.rule[0].apply_server_side_encryption_by_default[0].kms_master_key_id
}

# Enhanced CloudFront Distribution Outputs
output "cloudfront_distribution_id" {
  description = "The identifier for the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.id
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.arn
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The CloudFront distribution hosted zone ID"
  value       = aws_cloudfront_distribution.static_assets.hosted_zone_id
}

output "cloudfront_distribution_status" {
  description = "The current status of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.status
}

output "cloudfront_distribution_etag" {
  description = "The current version of the CloudFront distribution's information"
  value       = aws_cloudfront_distribution.static_assets.etag
}

output "cloudfront_distribution_enabled" {
  description = "Whether the CloudFront distribution is enabled"
  value       = aws_cloudfront_distribution.static_assets.enabled
}

output "cloudfront_distribution_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.is_ipv6_enabled
}

output "cloudfront_distribution_http_version" {
  description = "The HTTP version used by the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.http_version
}

output "cloudfront_distribution_price_class" {
  description = "The price class of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.price_class
}

# Enhanced CloudFront Origin Access Control Outputs
output "cloudfront_origin_access_control_id" {
  description = "The identifier for the CloudFront origin access control"
  value       = aws_cloudfront_origin_access_control.static_assets.id
}

output "cloudfront_origin_access_control_arn" {
  description = "The ARN of the CloudFront origin access control"
  value       = aws_cloudfront_origin_access_control.static_assets.arn
}

output "cloudfront_origin_access_control_name" {
  description = "The name of the CloudFront origin access control"
  value       = aws_cloudfront_origin_access_control.static_assets.name
}

# Enhanced CloudFront Function Outputs
output "cloudfront_function_arn" {
  description = "The ARN of the CloudFront function (if security headers are enabled)"
  value       = var.enable_security_headers ? aws_cloudfront_function.security_headers[0].arn : null
}

output "cloudfront_function_name" {
  description = "The name of the CloudFront function (if security headers are enabled)"
  value       = var.enable_security_headers ? aws_cloudfront_function.security_headers[0].name : null
}

output "cloudfront_function_status" {
  description = "The status of the CloudFront function (if security headers are enabled)"
  value       = var.enable_security_headers ? aws_cloudfront_function.security_headers[0].status : null
}

# Enhanced Logging Bucket Outputs
output "logs_bucket_id" {
  description = "The name of the logs S3 bucket (if logging is enabled)"
  value       = var.logging_config != null ? aws_s3_bucket.logs[0].id : null
}

output "logs_bucket_arn" {
  description = "The ARN of the logs S3 bucket (if logging is enabled)"
  value       = var.logging_config != null ? aws_s3_bucket.logs[0].arn : null
}

output "logs_bucket_versioning_status" {
  description = "The versioning status of the logs S3 bucket (if logging is enabled)"
  value       = var.logging_config != null ? aws_s3_bucket_versioning.logs[0].versioning_configuration[0].status : null
}

output "logs_bucket_encryption_algorithm" {
  description = "The encryption algorithm used for the logs S3 bucket (if logging is enabled)"
  value       = var.logging_config != null ? aws_s3_bucket_server_side_encryption_configuration.logs[0].rule[0].apply_server_side_encryption_by_default[0].sse_algorithm : null
}

# Enhanced KMS Outputs
output "kms_key_arn" {
  description = "The ARN of the KMS key (if KMS encryption is enabled)"
  value       = var.enable_kms_encryption ? aws_kms_key.cdn_encryption[0].arn : null
}

output "kms_key_id" {
  description = "The ID of the KMS key (if KMS encryption is enabled)"
  value       = var.enable_kms_encryption ? aws_kms_key.cdn_encryption[0].key_id : null
}

output "kms_key_alias" {
  description = "The alias of the KMS key (if KMS encryption is enabled)"
  value       = var.enable_kms_encryption ? aws_kms_alias.cdn_encryption[0].name : null
}

# Enhanced CloudWatch Alarms Outputs
output "cloudwatch_alarm_names" {
  description = "The names of the CloudWatch alarms (if enabled)"
  value       = var.enable_cloudwatch_alarms ? [for alarm in aws_cloudwatch_metric_alarm.cdn_alarms : alarm.alarm_name] : []
}

output "cloudwatch_alarm_arns" {
  description = "The ARNs of the CloudWatch alarms (if enabled)"
  value       = var.enable_cloudwatch_alarms ? [for alarm in aws_cloudwatch_metric_alarm.cdn_alarms : alarm.arn] : []
}

# Enhanced Field-level Encryption Outputs
output "field_level_encryption_config_id" {
  description = "The ID of the field-level encryption configuration (if enabled)"
  value       = var.enable_field_level_encryption ? aws_cloudfront_field_level_encryption_config.main[0].id : null
}

output "field_level_encryption_config_arn" {
  description = "The ARN of the field-level encryption configuration (if enabled)"
  value       = var.enable_field_level_encryption ? aws_cloudfront_field_level_encryption_config.main[0].arn : null
}

# Enhanced Real-time Logs Outputs
output "realtime_log_config_id" {
  description = "The ID of the real-time log configuration (if enabled)"
  value       = var.enable_realtime_logs ? aws_cloudfront_realtime_log_config.main[0].id : null
}

output "realtime_log_config_arn" {
  description = "The ARN of the real-time log configuration (if enabled)"
  value       = var.enable_realtime_logs ? aws_cloudfront_realtime_log_config.main[0].arn : null
}

# Enhanced Cost Optimization Outputs
output "budget_id" {
  description = "The ID of the budget (if cost optimization is enabled)"
  value       = var.enable_cost_optimization && var.cost_optimization_config.enable_budget_alerts ? aws_budgets_budget.cdn_budget[0].id : null
}

output "budget_arn" {
  description = "The ARN of the budget (if cost optimization is enabled)"
  value       = var.enable_cost_optimization && var.cost_optimization_config.enable_budget_alerts ? aws_budgets_budget.cdn_budget[0].arn : null
}

# Combined Outputs
output "cdn_url" {
  description = "The URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.static_assets.domain_name}"
}

output "cdn_aliases" {
  description = "The aliases of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.aliases
}

output "origin_domain" {
  description = "The origin domain name (S3 bucket regional domain name)"
  value       = aws_s3_bucket.static_assets.bucket_regional_domain_name
}

# Enhanced Security Outputs
output "security_headers_enabled" {
  description = "Whether security headers are enabled"
  value       = var.enable_security_headers
}

output "web_acl_associated" {
  description = "Whether a Web ACL is associated with the distribution"
  value       = var.web_acl_id != null
}

output "kms_encryption_enabled" {
  description = "Whether KMS encryption is enabled"
  value       = var.enable_kms_encryption
}

output "field_level_encryption_enabled" {
  description = "Whether field-level encryption is enabled"
  value       = var.enable_field_level_encryption
}

output "realtime_logs_enabled" {
  description = "Whether real-time logs are enabled"
  value       = var.enable_realtime_logs
}

# Enhanced Performance Outputs
output "compression_enabled" {
  description = "Whether compression is enabled for the cache behavior"
  value       = var.enable_compression
}

output "smooth_streaming_enabled" {
  description = "Whether smooth streaming is enabled for the cache behavior"
  value       = var.smooth_streaming
}

output "cache_policy_id" {
  description = "The cache policy ID used (if applicable)"
  value       = (!var.forward_query_string && var.forward_cookies == "none" && length(var.forward_headers) == 0) ? "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" : null
}

# Enhanced Cost and Performance Outputs
output "price_class" {
  description = "The price class of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.price_class
}

output "ipv6_enabled" {
  description = "Whether IPv6 is enabled for the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.is_ipv6_enabled
}

# Enhanced Cache Behavior Outputs
output "cache_behavior_allowed_methods" {
  description = "The allowed methods for the cache behavior"
  value       = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].allowed_methods
}

output "cache_behavior_cached_methods" {
  description = "The cached methods for the cache behavior"
  value       = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].cached_methods
}

output "cache_behavior_viewer_protocol_policy" {
  description = "The viewer protocol policy for the cache behavior"
  value       = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].viewer_protocol_policy
}

output "cache_behavior_compress" {
  description = "Whether compression is enabled for the cache behavior"
  value       = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].compress
}

# Enhanced TTL Outputs
output "cache_behavior_min_ttl" {
  description = "The minimum TTL for cached objects"
  value       = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].min_ttl
}

output "cache_behavior_default_ttl" {
  description = "The default TTL for cached objects"
  value       = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].default_ttl
}

output "cache_behavior_max_ttl" {
  description = "The maximum TTL for cached objects"
  value       = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].max_ttl
}

# Enhanced Configuration Summary
output "configuration_summary" {
  description = "A comprehensive summary of the CDN configuration"
  value = {
    distribution = {
      id = aws_cloudfront_distribution.static_assets.id
      domain_name = aws_cloudfront_distribution.static_assets.domain_name
      status = aws_cloudfront_distribution.static_assets.status
      enabled = aws_cloudfront_distribution.static_assets.enabled
      ipv6_enabled = aws_cloudfront_distribution.static_assets.is_ipv6_enabled
      price_class = aws_cloudfront_distribution.static_assets.price_class
      http_version = aws_cloudfront_distribution.static_assets.http_version
    }
    s3_bucket = {
      id = aws_s3_bucket.static_assets.id
      arn = aws_s3_bucket.static_assets.arn
      versioning_status = aws_s3_bucket_versioning.static_assets.versioning_configuration[0].status
      encryption_algorithm = aws_s3_bucket_server_side_encryption_configuration.static_assets.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm
    }
    security = {
      security_headers_enabled = var.enable_security_headers
      web_acl_associated = var.web_acl_id != null
      kms_encryption_enabled = var.enable_kms_encryption
      field_level_encryption_enabled = var.enable_field_level_encryption
    }
    performance = {
      compression_enabled = var.enable_compression
      smooth_streaming_enabled = var.smooth_streaming
      realtime_logs_enabled = var.enable_realtime_logs
    }
    monitoring = {
      cloudwatch_alarms_enabled = var.enable_cloudwatch_alarms
      logging_enabled = var.logging_config != null
      cost_optimization_enabled = var.enable_cost_optimization
    }
    cache_behavior = {
      allowed_methods = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].allowed_methods
      cached_methods = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].cached_methods
      viewer_protocol_policy = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].viewer_protocol_policy
      min_ttl = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].min_ttl
      default_ttl = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].default_ttl
      max_ttl = aws_cloudfront_distribution.static_assets.default_cache_behavior[0].max_ttl
    }
  }
}

# Enhanced Module Version
output "module_version" {
  description = "Version of the enhanced CDN module"
  value       = "2.0.0"
} 