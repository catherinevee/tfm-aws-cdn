# AWS CloudFront + S3 CDN Terraform Module

A comprehensive Terraform module for creating AWS CloudFront distributions with S3 origins for static asset delivery. This module provides a secure, scalable, and performant CDN solution with best practices for security, caching, and monitoring.

## Features

- **Secure S3 Origin**: Private S3 bucket with Origin Access Control (OAC)
- **CloudFront Distribution**: Global CDN with configurable cache behaviors
- **Security Headers**: Optional CloudFront Function for security headers
- **Logging**: Configurable CloudFront access logs with lifecycle management
- **Geo Restrictions**: Optional geographic access controls
- **Custom Error Pages**: Configurable error responses
- **Lambda@Edge Support**: Integration with Lambda@Edge functions
- **CloudFront Functions**: Support for CloudFront Functions
- **Web ACL Integration**: AWS WAF integration
- **IPv6 Support**: Native IPv6 support
- **Compression**: Automatic content compression
- **Versioning**: S3 bucket versioning for data protection

## Usage

### Basic Usage

```hcl
module "cdn" {
  source = "./tfm-aws-cdn"

  bucket_name        = "my-static-assets-bucket"
  distribution_name  = "my-cdn-distribution"
  
  common_tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
```

### Advanced Usage with Custom Domain

```hcl
module "cdn" {
  source = "./tfm-aws-cdn"

  bucket_name       = "my-static-assets-bucket"
  distribution_name = "my-cdn-distribution"
  
  aliases = ["cdn.example.com", "static.example.com"]
  
  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/example"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  
  # Custom cache behavior
  min_ttl     = 0
  default_ttl = 3600
  max_ttl     = 86400
  
  # Security
  enable_security_headers = true
  web_acl_id             = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/example"
  
  # Logging
  logging_config = {
    bucket          = "my-cloudfront-logs-bucket"
    include_cookies = true
    prefix          = "cloudfront-logs/"
  }
  
  # Geo restrictions
  geo_restrictions = {
    restriction_type = "whitelist"
    locations        = ["US", "CA", "GB"]
  }
  
  common_tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
```

### Usage with Lambda@Edge

```hcl
module "cdn" {
  source = "./tfm-aws-cdn"

  bucket_name       = "my-static-assets-bucket"
  distribution_name = "my-cdn-distribution"
  
  lambda_function_associations = [
    {
      event_type   = "viewer-request"
      lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:my-lambda-function:1"
      include_body = false
    },
    {
      event_type   = "origin-response"
      lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:my-response-function:1"
      include_body = false
    }
  ]
  
  common_tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Inputs

### Required

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket for static assets | `string` | n/a | yes |
| distribution_name | Name for the CloudFront distribution | `string` | n/a | yes |

### Optional

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Whether the CloudFront distribution is enabled | `bool` | `true` | no |
| enable_ipv6 | Whether to enable IPv6 support | `bool` | `true` | no |
| comment | Comment for the CloudFront distribution | `string` | `"CDN distribution for static assets"` | no |
| default_root_object | Default root object for the CloudFront distribution | `string` | `"index.html"` | no |
| price_class | Price class for the CloudFront distribution | `string` | `"PriceClass_100"` | no |
| aliases | List of aliases for the CloudFront distribution | `list(string)` | `[]` | no |
| enable_versioning | Whether to enable versioning on the S3 bucket | `bool` | `true` | no |
| allowed_methods | Allowed HTTP methods for the cache behavior | `list(string)` | `["GET", "HEAD", "OPTIONS"]` | no |
| cached_methods | Cached HTTP methods for the cache behavior | `list(string)` | `["GET", "HEAD"]` | no |
| forward_query_string | Whether to forward query strings to the origin | `bool` | `false` | no |
| forward_cookies | How to forward cookies to the origin | `string` | `"none"` | no |
| viewer_protocol_policy | Viewer protocol policy for the cache behavior | `string` | `"redirect-to-https"` | no |
| min_ttl | Minimum TTL for cached objects | `number` | `0` | no |
| default_ttl | Default TTL for cached objects | `number` | `86400` | no |
| max_ttl | Maximum TTL for cached objects | `number` | `31536000` | no |
| enable_compression | Whether to enable compression for the cache behavior | `bool` | `true` | no |
| enable_security_headers | Whether to enable security headers via CloudFront Function | `bool` | `true` | no |
| web_acl_id | Web ACL ID to associate with the CloudFront distribution | `string` | `null` | no |
| viewer_certificate | Viewer certificate configuration | `object` | `null` | no |
| geo_restrictions | Geo restrictions configuration | `object` | `null` | no |
| logging_config | Logging configuration for CloudFront | `object` | `null` | no |
| lambda_function_associations | Lambda@Edge function associations | `list(object)` | `[]` | no |
| function_associations | CloudFront function associations | `list(object)` | `[]` | no |
| custom_error_responses | Custom error responses | `list(object)` | `[]` | no |
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_id | The name of the S3 bucket |
| s3_bucket_arn | The ARN of the S3 bucket |
| s3_bucket_domain_name | The bucket domain name |
| s3_bucket_regional_domain_name | The bucket region-specific domain name |
| cloudfront_distribution_id | The identifier for the CloudFront distribution |
| cloudfront_distribution_arn | The ARN of the CloudFront distribution |
| cloudfront_distribution_domain_name | The domain name of the CloudFront distribution |
| cloudfront_distribution_hosted_zone_id | The CloudFront distribution hosted zone ID |
| cloudfront_distribution_status | The current status of the CloudFront distribution |
| cloudfront_distribution_etag | The current version of the CloudFront distribution's information |
| cloudfront_origin_access_control_id | The identifier for the CloudFront origin access control |
| cloudfront_origin_access_control_arn | The ARN of the CloudFront origin access control |
| cloudfront_function_arn | The ARN of the CloudFront function (if security headers are enabled) |
| cloudfront_function_name | The name of the CloudFront function (if security headers are enabled) |
| logs_bucket_id | The name of the logs S3 bucket (if logging is enabled) |
| logs_bucket_arn | The ARN of the logs S3 bucket (if logging is enabled) |
| cdn_url | The URL of the CloudFront distribution |
| cdn_aliases | The aliases of the CloudFront distribution |
| origin_domain | The origin domain name (S3 bucket regional domain name) |
| security_headers_enabled | Whether security headers are enabled |
| web_acl_associated | Whether a Web ACL is associated with the distribution |
| price_class | The price class of the CloudFront distribution |
| ipv6_enabled | Whether IPv6 is enabled for the CloudFront distribution |
| cache_behavior_allowed_methods | The allowed methods for the cache behavior |
| cache_behavior_cached_methods | The cached methods for the cache behavior |
| cache_behavior_viewer_protocol_policy | The viewer protocol policy for the cache behavior |
| cache_behavior_min_ttl | The minimum TTL for cached objects |
| cache_behavior_default_ttl | The default TTL for cached objects |
| cache_behavior_max_ttl | The maximum TTL for cached objects |

## Examples

### Basic Example

See the `examples/basic` directory for a simple implementation.

### Advanced Example

See the `examples/advanced` directory for a comprehensive implementation with custom domains, security, and monitoring.

### Website Example

See the `examples/website` directory for a complete website hosting setup.

## Security Features

### S3 Bucket Security

- **Private Access**: S3 bucket is completely private with no public access
- **Origin Access Control**: Uses CloudFront Origin Access Control (OAC) for secure access
- **Server-Side Encryption**: AES256 encryption enabled by default
- **Versioning**: Optional versioning for data protection
- **Bucket Policy**: Restrictive policy allowing only CloudFront access

### CloudFront Security

- **HTTPS Only**: Redirects HTTP to HTTPS by default
- **Security Headers**: Optional CloudFront Function adds security headers
- **Web ACL Integration**: Support for AWS WAF integration
- **Geo Restrictions**: Optional geographic access controls
- **Custom Error Pages**: Configurable error responses

### Security Headers

When `enable_security_headers = true`, the following headers are added:

- `Strict-Transport-Security`: Enforces HTTPS
- `X-Content-Type-Options`: Prevents MIME type sniffing
- `X-Frame-Options`: Prevents clickjacking
- `X-XSS-Protection`: XSS protection
- `Referrer-Policy`: Controls referrer information
- `Content-Security-Policy`: Content security policy
- `Permissions-Policy`: Feature policy

## Performance Features

### Caching

- **Configurable TTL**: Customizable cache durations
- **Compression**: Automatic content compression
- **Cache Headers**: Proper cache control headers
- **Origin Optimization**: Optimized origin requests

### Global Distribution

- **Edge Locations**: Global content delivery
- **IPv6 Support**: Native IPv6 support
- **Price Classes**: Configurable price classes for cost optimization

## Monitoring and Logging

### CloudFront Logs

- **Access Logs**: Detailed access logging
- **Log Retention**: Configurable log retention with lifecycle policies
- **Log Analysis**: Structured logs for analysis

### Metrics

- **CloudWatch Integration**: Native CloudWatch metrics
- **Real-time Metrics**: Real-time performance monitoring
- **Cost Tracking**: Detailed cost tracking and optimization

## Best Practices

### Security

1. **Always use HTTPS**: Set `viewer_protocol_policy` to `"redirect-to-https"`
2. **Enable security headers**: Set `enable_security_headers = true`
3. **Use Web ACL**: Associate a Web ACL for additional protection
4. **Geo restrictions**: Use geo restrictions when appropriate
5. **Regular updates**: Keep the module updated for security patches

### Performance

1. **Optimize TTL**: Set appropriate cache TTL values
2. **Enable compression**: Keep `enable_compression = true`
3. **Use appropriate price class**: Choose the right price class for your needs
4. **Monitor performance**: Use CloudWatch metrics for optimization

### Cost Optimization

1. **Price class selection**: Use `PriceClass_100` for most use cases
2. **Log retention**: Set appropriate log retention periods
3. **Monitor usage**: Track CloudFront usage and optimize
4. **Cache optimization**: Maximize cache hit rates

## Troubleshooting

### Common Issues

1. **Distribution not updating**: Check CloudFront invalidation
2. **S3 access denied**: Verify Origin Access Control configuration
3. **HTTPS errors**: Check certificate configuration
4. **Cache issues**: Verify TTL settings and invalidate if needed

### Debugging

1. **Check CloudFront logs**: Enable logging for debugging
2. **Verify bucket policy**: Ensure S3 bucket policy is correct
3. **Test origin access**: Verify CloudFront can access S3
4. **Check security headers**: Verify security headers are being applied

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For support and questions:

1. Check the documentation
2. Review the examples
3. Open an issue on GitHub
4. Contact the maintainers

## Changelog

### Version 1.0.0

- Initial release
- Basic CloudFront + S3 CDN functionality
- Security headers support
- Logging configuration
- Comprehensive documentation