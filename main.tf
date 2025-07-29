# S3 Bucket for static assets
resource "aws_s3_bucket" "static_assets" {
  bucket = var.bucket_name

  tags = merge(var.common_tags, {
    Name = var.bucket_name
    Purpose = "Static Assets Storage"
  })
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_assets.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.static_assets.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.static_assets]
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "static_assets" {
  name                              = "${var.distribution_name}-oac"
  description                       = "Origin Access Control for ${var.distribution_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "static_assets" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.enable_ipv6
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases

  # Origin configuration
  origin {
    domain_name              = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.static_assets.id
    origin_id                = "S3-${aws_s3_bucket.static_assets.bucket}"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = "S3-${aws_s3_bucket.static_assets.bucket}"

    forwarded_values {
      query_string = var.forward_query_string
      cookies {
        forward = var.forward_cookies
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl

    # Compression
    compress = var.enable_compression

    # Lambda@Edge functions
    dynamic "lambda_function_association" {
      for_each = var.lambda_function_associations
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lookup(lambda_function_association.value, "include_body", false)
      }
    }

    # Function associations
    dynamic "function_association" {
      for_each = var.function_associations
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  # Custom error responses
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  # Viewer certificate
  dynamic "viewer_certificate" {
    for_each = var.viewer_certificate != null ? [var.viewer_certificate] : []
    content {
      acm_certificate_arn            = lookup(viewer_certificate.value, "acm_certificate_arn", null)
      ssl_support_method             = lookup(viewer_certificate.value, "ssl_support_method", null)
      minimum_protocol_version       = lookup(viewer_certificate.value, "minimum_protocol_version", "TLSv1.2_2021")
      cloudfront_default_certificate = lookup(viewer_certificate.value, "cloudfront_default_certificate", null)
      iam_certificate_id             = lookup(viewer_certificate.value, "iam_certificate_id", null)
    }
  }

  # Geo restrictions
  dynamic "restrictions" {
    for_each = var.geo_restrictions != null ? [var.geo_restrictions] : []
    content {
      geo_restriction {
        restriction_type = restrictions.value.restriction_type
        locations        = lookup(restrictions.value, "locations", [])
      }
    }
  }

  # Logging configuration
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      include_cookies = lookup(logging_config.value, "include_cookies", false)
      bucket          = logging_config.value.bucket
      prefix          = lookup(logging_config.value, "prefix", null)
    }
  }

  # Web ACL
  web_acl_id = var.web_acl_id

  tags = merge(var.common_tags, {
    Name = var.distribution_name
    Purpose = "CDN Distribution"
  })
}

# CloudFront Function for security headers (optional)
resource "aws_cloudfront_function" "security_headers" {
  count   = var.enable_security_headers ? 1 : 0
  name    = "${var.distribution_name}-security-headers"
  runtime = "cloudfront-js-1.0"
  comment = "Security headers function for ${var.distribution_name}"
  publish = true
  code    = file("${path.module}/functions/security-headers.js")
}

# CloudFront Function association for security headers
resource "aws_cloudfront_function_association" "security_headers" {
  count = var.enable_security_headers ? 1 : 0

  function_arn   = aws_cloudfront_function.security_headers[0].arn
  event_type     = "viewer-response"
  distribution_id = aws_cloudfront_distribution.static_assets.id
}

# S3 Bucket for CloudFront logs (if logging is enabled)
resource "aws_s3_bucket" "logs" {
  count  = var.logging_config != null ? 1 : 0
  bucket = "${var.bucket_name}-logs"

  tags = merge(var.common_tags, {
    Name = "${var.bucket_name}-logs"
    Purpose = "CloudFront Logs"
  })
}

# S3 Bucket versioning for logs
resource "aws_s3_bucket_versioning" "logs" {
  count  = var.logging_config != null ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket server-side encryption for logs
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count  = var.logging_config != null ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket lifecycle for logs
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count  = var.logging_config != null ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    id     = "log_retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
} 