# S3 Bucket Outputs
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

# CloudFront Distribution Outputs
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

# CloudFront Origin Access Control Outputs
output "cloudfront_origin_access_control_id" {
  description = "The identifier for the CloudFront origin access control"
  value       = aws_cloudfront_origin_access_control.static_assets.id
}

output "cloudfront_origin_access_control_arn" {
  description = "The ARN of the CloudFront origin access control"
  value       = aws_cloudfront_origin_access_control.static_assets.arn
}

# CloudFront Function Outputs
output "cloudfront_function_arn" {
  description = "The ARN of the CloudFront function (if security headers are enabled)"
  value       = var.enable_security_headers ? aws_cloudfront_function.security_headers[0].arn : null
}

output "cloudfront_function_name" {
  description = "The name of the CloudFront function (if security headers are enabled)"
  value       = var.enable_security_headers ? aws_cloudfront_function.security_headers[0].name : null
}

# Logging Bucket Outputs
output "logs_bucket_id" {
  description = "The name of the logs S3 bucket (if logging is enabled)"
  value       = var.logging_config != null ? aws_s3_bucket.logs[0].id : null
}

output "logs_bucket_arn" {
  description = "The ARN of the logs S3 bucket (if logging is enabled)"
  value       = var.logging_config != null ? aws_s3_bucket.logs[0].arn : null
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

# Security Outputs
output "security_headers_enabled" {
  description = "Whether security headers are enabled"
  value       = var.enable_security_headers
}

output "web_acl_associated" {
  description = "Whether a Web ACL is associated with the distribution"
  value       = var.web_acl_id != null
}

# Cost and Performance Outputs
output "price_class" {
  description = "The price class of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.price_class
}

output "ipv6_enabled" {
  description = "Whether IPv6 is enabled for the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets.is_ipv6_enabled
}

# Cache Behavior Outputs
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

# TTL Outputs
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