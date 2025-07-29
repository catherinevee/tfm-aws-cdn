# Advanced CloudFront + S3 CDN Example

This example demonstrates advanced usage of the CloudFront + S3 CDN module with comprehensive configuration including logging, custom error responses, and security features.

## What this example creates

- S3 bucket for static assets (private, encrypted, versioned)
- CloudFront distribution with custom cache behavior
- Origin Access Control for secure S3 access
- Security headers via CloudFront Function
- Custom error responses for SPA routing
- CloudFront access logging with lifecycle management
- Separate S3 bucket for logs with retention policies
- Proper tagging for resource management

## Features Demonstrated

### Custom Cache Behavior
- Configurable TTL values for different caching scenarios
- Optimized for single-page applications (SPA)

### Security
- Security headers enabled by default
- HTTPS redirect enforced
- Private S3 bucket with Origin Access Control

### Logging and Monitoring
- CloudFront access logs stored in S3
- Log retention policies (30 days Standard-IA, 90 days Glacier, 1 year expiration)
- Encrypted log storage

### Error Handling
- Custom error responses for 404 and 403 errors
- SPA-friendly routing (returns index.html for missing routes)

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Destroy the resources when done
terraform destroy
```

## Outputs

After applying this configuration, you'll get:

- `cdn_url`: The CloudFront distribution URL
- `s3_bucket_name`: The S3 bucket name for static assets
- `cloudfront_distribution_id`: The CloudFront distribution ID
- `cloudfront_domain_name`: The CloudFront domain name
- `logs_bucket_name`: The S3 bucket name for logs
- `security_headers_enabled`: Whether security headers are enabled
- `cache_behavior_ttl`: Cache behavior TTL settings

## Customization Options

### Lambda@Edge Integration
The example includes commented code showing how to integrate Lambda@Edge functions. To use this:

1. Create your Lambda function
2. Uncomment the `cdn_with_lambda` module
3. Update the Lambda ARN with your actual function

### Custom Domain Setup
To add custom domains:

1. Create an ACM certificate in us-east-1
2. Add the `aliases` and `viewer_certificate` variables
3. Configure DNS records

### Web ACL Integration
To add AWS WAF protection:

1. Create a Web ACL
2. Add the `web_acl_id` variable

## Best Practices Demonstrated

1. **Security**: Private S3 bucket with Origin Access Control
2. **Performance**: Optimized cache settings for SPA
3. **Monitoring**: Comprehensive logging with retention policies
4. **Cost Optimization**: Lifecycle policies for log storage
5. **Error Handling**: Custom error responses for better UX
6. **Tagging**: Proper resource tagging for management

## Next Steps

1. Upload your static assets to the S3 bucket
2. Test the custom error responses
3. Monitor CloudFront logs for performance insights
4. Consider adding Web ACL for additional security
5. Set up custom domain and SSL certificate 