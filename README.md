# AWS CloudFront + S3 CDN Terraform Module

Sets up a CloudFront distribution with an S3 bucket for hosting static websites, SPAs, or asset delivery. Uses Origin Access Control (OAC) instead of the legacy OAI approach.

## What it does

Creates a private S3 bucket that only CloudFront can access, plus a CloudFront distribution with sensible defaults for caching and security. Good for hosting React apps, documentation sites, or serving images and files.

**Key features:**
- Private S3 bucket with CloudFront-only access
- Security headers via CloudFront Functions
- Optional WAF integration and geo-blocking
- Lambda@Edge hooks for custom logic
- Cost-optimized caching defaults

## Quick Start

```hcl
module "cdn" {
  source = "./tfm-aws-cdn"

  bucket_name       = "myapp-static-assets"
  distribution_name = "myapp-cdn"
  
  tags = {
    Environment = "production"
    App         = "myapp"
  }
}
```

That's it. Your S3 bucket and CloudFront distribution will be created with security headers, HTTPS redirects, and compression enabled.

### With custom domain

```hcl
module "cdn" {
  source = "./tfm-aws-cdn"

  bucket_name       = "myapp-static-assets" 
  distribution_name = "myapp-cdn"
  aliases           = ["cdn.myapp.com"]
  
  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/your-cert"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

### With Lambda@Edge

```hcl
module "cdn" {
  source = "./tfm-aws-cdn"

  bucket_name       = "myapp-static-assets"
  distribution_name = "myapp-cdn"
  
  # Add custom headers or modify requests/responses
  lambda_function_associations = [
    {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.auth_check.qualified_arn
    }
  ]
}

## Configuration

### Required inputs

| Name | Description |
|------|-------------|
| `bucket_name` | S3 bucket name for your static files |
| `distribution_name` | Name for the CloudFront distribution |

### Common options

| Name | Description | Default |
|------|-------------|---------|
| `aliases` | Custom domains for the CDN | `[]` |
| `enable_security_headers` | Adds security headers to responses | `true` |
| `price_class` | CloudFront price class (`PriceClass_100`, `200`, `All`) | `PriceClass_100` |
| `default_ttl` | Cache duration in seconds | `86400` (1 day) |
| `web_acl_id` | AWS WAF web ACL ARN | `null` |
| `viewer_certificate` | SSL certificate configuration | CloudFront default |
| `geo_restrictions` | Country-based access restrictions | None |

## Outputs

Access your CDN through `module.cdn.cdn_url` or your custom domain if configured.

| Output | Description |
|--------|-------------|
| `cdn_url` | CloudFront distribution URL |
| `s3_bucket_id` | S3 bucket name |
| `cloudfront_distribution_id` | CloudFront distribution ID (for invalidations) |

See `outputs.tf` for the full list.

## Common Gotchas

**Certificate validation**: ACM certificates for CloudFront must be in `us-east-1`, even if your other resources are elsewhere.

**Invalidations cost money**: Each invalidation is $0.005 per path. Consider using versioned filenames instead.

**S3 bucket naming**: Bucket names are global. Add a random suffix or your account ID to avoid conflicts.

**Custom domains need DNS**: After applying, add a CNAME record pointing your domain to the CloudFront distribution URL.

**Security headers**: The default security headers are pretty strict. Check if they work with your app before enabling in production.

## Cache behavior notes

- By default, only `GET` and `HEAD` requests are cached
- Query strings and cookies are ignored (not forwarded to S3)
- Use `forward_query_string = true` for SPAs that need query parameters
- Default cache time is 1 day; static assets can cache much longer

## Cost optimization

- `PriceClass_100` uses only the cheapest edge locations (US, Canada, Europe)
- `PriceClass_200` adds Asia, Africa, Oceania, Middle East
- `PriceClass_All` includes South America (most expensive)
- For most use cases, `PriceClass_100` is fine

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 5.0