# Outputs for basic example
output "cdn_url" {
  description = "The URL of the CloudFront distribution"
  value       = module.cdn_basic.cdn_url
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.cdn_basic.s3_bucket_id
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.cdn_basic.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cdn_basic.cloudfront_distribution_domain_name
} 