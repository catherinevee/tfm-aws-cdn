# Outputs for website example
output "website_url" {
  description = "The URL of the website served via CloudFront"
  value       = module.website_cdn.cdn_url
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket hosting the website"
  value       = module.website_cdn.s3_bucket_id
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.website_cdn.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.website_cdn.cloudfront_distribution_domain_name
}

output "logs_bucket_name" {
  description = "The name of the logs S3 bucket"
  value       = aws_s3_bucket.logs.bucket
}

output "security_headers_enabled" {
  description = "Whether security headers are enabled"
  value       = module.website_cdn.security_headers_enabled
}

output "website_files" {
  description = "List of website files uploaded to S3"
  value = [
    aws_s3_object.index_html.key,
    aws_s3_object.styles_css.key,
    aws_s3_object.script_js.key,
    aws_s3_object.favicon_ico.key
  ]
} 