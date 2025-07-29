# Test outputs
output "test_cdn_url" {
  description = "The URL of the test CloudFront distribution"
  value       = module.test_cdn.cdn_url
}

output "test_s3_bucket_name" {
  description = "The name of the test S3 bucket"
  value       = module.test_cdn.s3_bucket_id
}

output "test_cloudfront_distribution_id" {
  description = "The ID of the test CloudFront distribution"
  value       = module.test_cdn.cloudfront_distribution_id
}

output "test_cloudfront_domain_name" {
  description = "The domain name of the test CloudFront distribution"
  value       = module.test_cdn.cloudfront_distribution_domain_name
} 