# Basic CloudFront + S3 CDN Example

This example demonstrates the basic usage of the CloudFront + S3 CDN module with minimal configuration.

## What this example creates

- S3 bucket for static assets (private, encrypted, versioned)
- CloudFront distribution with default settings
- Origin Access Control for secure S3 access
- Security headers via CloudFront Function
- Proper tagging for resource management

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
- `s3_bucket_name`: The S3 bucket name
- `cloudfront_distribution_id`: The CloudFront distribution ID
- `cloudfront_domain_name`: The CloudFront domain name

## Next Steps

1. Upload your static assets to the S3 bucket
2. Access your content via the CloudFront URL
3. Consider using the advanced example for production deployments 