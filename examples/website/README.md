# Website Hosting Example

This example demonstrates how to host a complete website using the CloudFront + S3 CDN module. It includes a sample website with HTML, CSS, and JavaScript files that are automatically uploaded to S3 and served via CloudFront.

## What this example creates

- S3 bucket for website assets (private, encrypted, versioned)
- CloudFront distribution optimized for website hosting
- Origin Access Control for secure S3 access
- Security headers via CloudFront Function
- Custom error responses for SPA routing (404 → index.html)
- CloudFront access logging with lifecycle management
- Sample website files (HTML, CSS, JS, favicon)
- Proper tagging for resource management

## Features Demonstrated

### Website Optimization
- Default root object set to `index.html`
- Custom cache behavior optimized for websites
- SPA-friendly routing with custom error responses
- Automatic file uploads to S3

### Security
- Security headers enabled by default
- HTTPS redirect enforced
- Private S3 bucket with Origin Access Control

### Performance
- Optimized TTL settings for different content types
- Compression enabled
- Global CDN distribution

### Monitoring
- CloudFront access logs stored in S3
- Log retention policies
- Encrypted log storage

## Sample Website

The example includes a modern, responsive website that showcases:

- **Modern Design**: Clean, professional layout with gradients and animations
- **Responsive**: Works on desktop, tablet, and mobile devices
- **Interactive**: JavaScript animations and performance metrics
- **SEO Friendly**: Proper HTML structure and meta tags
- **Performance**: Optimized for fast loading via CDN

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Visit your website
# The URL will be displayed in the outputs
```

## Outputs

After applying this configuration, you'll get:

- `website_url`: The CloudFront URL for your website
- `s3_bucket_name`: The S3 bucket name hosting the website
- `cloudfront_distribution_id`: The CloudFront distribution ID
- `cloudfront_domain_name`: The CloudFront domain name
- `logs_bucket_name`: The S3 bucket name for logs
- `security_headers_enabled`: Whether security headers are enabled
- `website_files`: List of files uploaded to S3

## Customization

### Adding Custom Domain

To use a custom domain:

1. Create an ACM certificate in us-east-1
2. Uncomment and configure the `aliases` and `viewer_certificate` variables
3. Configure DNS records to point to CloudFront

```hcl
aliases = ["www.example.com", "example.com"]

viewer_certificate = {
  acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
}
```

### Adding More Files

To add more website files:

```hcl
resource "aws_s3_object" "new_file" {
  bucket       = module.website_cdn.s3_bucket_id
  key          = "path/to/file.ext"
  content      = file("${path.module}/files/file.ext")
  content_type = "appropriate/mime-type"
}
```

### Custom Cache Behavior

For different file types, you can create additional cache behaviors:

```hcl
# Example: Different cache settings for images
resource "aws_cloudfront_cache_policy" "images" {
  name        = "images-cache-policy"
  comment     = "Cache policy for images"
  default_ttl = 86400  # 24 hours
  max_ttl     = 31536000  # 1 year
  min_ttl     = 0
}
```

## Best Practices Demonstrated

1. **Security**: Private S3 bucket with Origin Access Control
2. **Performance**: Optimized cache settings for different content types
3. **Monitoring**: Comprehensive logging with retention policies
4. **Cost Optimization**: Lifecycle policies for log storage
5. **User Experience**: SPA-friendly routing and fast loading
6. **Maintenance**: Proper resource tagging and organization

## Next Steps

1. Visit your website URL to see the demo
2. Customize the website files in the `files/` directory
3. Add your own content and styling
4. Consider adding a custom domain
5. Set up monitoring and alerts
6. Configure CI/CD for automated deployments

## Troubleshooting

### Website Not Loading
- Check that the CloudFront distribution is deployed
- Verify the S3 bucket contains the files
- Check CloudFront logs for errors

### Files Not Updating
- CloudFront caches content - you may need to invalidate the cache
- Check that new files are uploaded to S3
- Verify file paths and content types

### Performance Issues
- Monitor CloudFront metrics in CloudWatch
- Check cache hit rates
- Optimize file sizes and compression 