# Outputs for advanced example
output "cdn_url" {
  description = "The URL of the CloudFront distribution"
  value       = module.cdn_advanced.cdn_url
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.cdn_advanced.s3_bucket_id
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.cdn_advanced.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cdn_advanced.cloudfront_distribution_domain_name
}

output "logs_bucket_name" {
  description = "The name of the logs S3 bucket"
  value       = aws_s3_bucket.logs.bucket
}

output "security_headers_enabled" {
  description = "Whether security headers are enabled"
  value       = module.cdn_advanced.security_headers_enabled
}

output "cache_behavior_ttl" {
  description = "Cache behavior TTL settings"
  value = {
    min_ttl     = module.cdn_advanced.cache_behavior_min_ttl
    default_ttl = module.cdn_advanced.cache_behavior_default_ttl
    max_ttl     = module.cdn_advanced.cache_behavior_max_ttl
  }
} 