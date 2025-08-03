# Enhanced CDN Module with comprehensive customization options
# This module provides a highly configurable CloudFront + S3 CDN solution

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Enhanced locals for compliance tagging and custom naming
locals {
  enhanced_tags = var.enable_compliance_tagging ? merge(var.common_tags, var.compliance_tags) : var.common_tags
  
  # Custom naming for resources
  origin_access_control_name = coalesce(var.origin_access_control_name, "${var.distribution_name}-oac")
  origin_access_control_description = coalesce(var.origin_access_control_description, "Origin Access Control for ${var.distribution_name}")
  security_headers_function_name = coalesce(var.security_headers_function_name, "${var.distribution_name}-security-headers")
  security_headers_function_comment = coalesce(var.security_headers_function_comment, "Security headers function for ${var.distribution_name}")
  logs_bucket_name = coalesce(var.logs_bucket_name, "${var.bucket_name}-logs")
  kms_key_alias = "${var.distribution_name}-cdn-key"
}

# Enhanced KMS Key for encryption
resource "aws_kms_key" "cdn_encryption" {
  count = var.enable_kms_encryption ? 1 : 0

  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_enable_rotation

  policy = var.kms_key_policy != null ? var.kms_key_policy : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.enhanced_tags, var.kms_key_tags, {
    Name = local.kms_key_alias
  })
}

resource "aws_kms_alias" "cdn_encryption" {
  count = var.enable_kms_encryption ? 1 : 0

  name          = "alias/${local.kms_key_alias}"
  target_key_id = aws_kms_key.cdn_encryption[0].key_id
}

# Enhanced S3 Bucket for static assets
resource "aws_s3_bucket" "static_assets" {
  bucket = var.bucket_name

  tags = merge(local.enhanced_tags, var.s3_bucket_tags, {
    Name = var.bucket_name
    Purpose = "Static Assets Storage"
  })
}

# Enhanced S3 Bucket versioning
resource "aws_s3_bucket_versioning" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  versioning_configuration {
    status = var.enable_versioning ? var.s3_bucket_versioning_status : "Disabled"
  }
}

# Enhanced S3 Bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_bucket_encryption_algorithm
      kms_master_key_id = var.s3_bucket_encryption_algorithm == "aws:kms" ? (var.s3_bucket_kms_key_id != null ? var.s3_bucket_kms_key_id : aws_kms_key.cdn_encryption[0].arn) : null
    }
    bucket_key_enabled = var.s3_bucket_key_enabled
  }
}

# Enhanced S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = var.s3_bucket_public_access_block.block_public_acls
  block_public_policy     = var.s3_bucket_public_access_block.block_public_policy
  ignore_public_acls      = var.s3_bucket_public_access_block.ignore_public_acls
  restrict_public_buckets = var.s3_bucket_public_access_block.restrict_public_buckets
}

# Enhanced S3 Bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "static_assets" {
  count  = length(var.s3_bucket_lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.static_assets.id

  dynamic "rule" {
    for_each = var.s3_bucket_lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "transition" {
        for_each = rule.value.transition
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition
        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }
}

# Enhanced S3 Bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  policy = var.s3_bucket_policy != null ? var.s3_bucket_policy : jsonencode({
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

# Enhanced CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "static_assets" {
  name                              = local.origin_access_control_name
  description                       = local.origin_access_control_description
  origin_access_control_origin_type = var.origin_access_control_origin_type
  signing_behavior                  = var.origin_access_control_signing_behavior
  signing_protocol                  = var.origin_access_control_signing_protocol
}

# Enhanced CloudFront Distribution
resource "aws_cloudfront_distribution" "static_assets" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.enable_ipv6
  comment             = var.comment
  default_root_object = var.default_root_object
  http_version        = var.http_version
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  price_class         = var.price_class
  aliases             = var.aliases

  # Enhanced Origin configuration
  origin {
    domain_name              = var.origin_config != null ? var.origin_config.domain_name : aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_access_control_id = var.origin_config != null ? var.origin_config.origin_access_control_id : aws_cloudfront_origin_access_control.static_assets.id
    origin_id                = var.origin_config != null ? var.origin_config.origin_id : "S3-${aws_s3_bucket.static_assets.bucket}"
    origin_path              = var.origin_config != null ? var.origin_config.origin_path : null

    # Enhanced Origin Shield
    dynamic "origin_shield" {
      for_each = var.origin_config != null && var.origin_config.origin_shield != null ? [var.origin_config.origin_shield] : []
      content {
        enabled              = origin_shield.value.enabled
        origin_shield_region = origin_shield.value.origin_shield_region
      }
    }

    # Enhanced Custom Origin Configuration
    dynamic "custom_origin_config" {
      for_each = var.origin_config != null && var.origin_config.custom_origin_config != null ? [var.origin_config.custom_origin_config] : []
      content {
        http_port                = custom_origin_config.value.http_port
        https_port               = custom_origin_config.value.https_port
        origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
        origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
        origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", 30)
        origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", 5)
      }
    }

    # Default S3 Origin Configuration
    dynamic "s3_origin_config" {
      for_each = var.origin_config == null || var.origin_config.custom_origin_config == null ? [1] : []
      content {
        origin_access_identity = ""
      }
    }

    # Enhanced Custom Headers
    dynamic "custom_header" {
      for_each = var.origin_config != null ? var.origin_config.custom_header : []
      content {
        name  = custom_header.value.name
        value = custom_header.value.value
      }
    }
  }

  # Enhanced Default cache behavior
  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = var.origin_config != null ? var.origin_config.origin_id : "S3-${aws_s3_bucket.static_assets.bucket}"

    # Enhanced Forwarded Values
    dynamic "forwarded_values" {
      for_each = var.forward_query_string || var.forward_cookies != "none" || length(var.forward_headers) > 0 ? [1] : []
      content {
        query_string = var.forward_query_string
        headers      = length(var.forward_headers) > 0 ? var.forward_headers : null

        cookies {
          forward = var.forward_cookies
          dynamic "whitelisted_names" {
            for_each = var.forward_cookies == "whitelist" ? var.forward_cookies_whitelist : []
            content {
              name = whitelisted_names.value
            }
          }
        }
      }
    }

    # Enhanced Cache Policy (if no forwarded_values)
    cache_policy_id = (!var.forward_query_string && var.forward_cookies == "none" && length(var.forward_headers) == 0) ? "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" : null # Managed-CachingOptimized

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl

    # Enhanced Compression
    compress = var.enable_compression

    # Enhanced Smooth Streaming
    smooth_streaming = var.smooth_streaming

    # Enhanced Trusted Signers and Key Groups
    dynamic "trusted_signers" {
      for_each = length(var.trusted_signers) > 0 ? var.trusted_signers : []
      content {
        aws_account_number = trusted_signers.value
      }
    }

    dynamic "trusted_key_groups" {
      for_each = length(var.trusted_key_groups) > 0 ? var.trusted_key_groups : []
      content {
        key_group_id = trusted_key_groups.value
      }
    }

    # Enhanced Real-time Log Configuration
    realtime_log_config_arn = var.realtime_log_config_arn

    # Enhanced Response Headers Policy
    response_headers_policy_id = var.response_headers_policy_id

    # Enhanced Lambda@Edge functions
    dynamic "lambda_function_association" {
      for_each = var.lambda_function_associations
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lookup(lambda_function_association.value, "include_body", false)
      }
    }

    # Enhanced Function associations
    dynamic "function_association" {
      for_each = var.function_associations
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  # Enhanced Custom error responses
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  # Enhanced Viewer certificate
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

  # Enhanced Geo restrictions
  dynamic "restrictions" {
    for_each = var.geo_restrictions != null ? [var.geo_restrictions] : []
    content {
      geo_restriction {
        restriction_type = restrictions.value.restriction_type
        locations        = lookup(restrictions.value, "locations", [])
      }
    }
  }

  # Enhanced Logging configuration
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      include_cookies = lookup(logging_config.value, "include_cookies", false)
      bucket          = logging_config.value.bucket
      prefix          = lookup(logging_config.value, "prefix", null)
    }
  }

  # Enhanced Web ACL
  web_acl_id = var.web_acl_id



  tags = merge(local.enhanced_tags, {
    Name = var.distribution_name
    Purpose = "CDN Distribution"
  })
}

# Enhanced CloudFront Field-level Encryption Configuration
resource "aws_cloudfront_field_level_encryption_config" "main" {
  count = var.enable_field_level_encryption ? 1 : 0

  comment = "Field-level encryption for ${var.distribution_name}"

  dynamic "query_arg_profile_config" {
    for_each = var.field_level_encryption_config != null && var.field_level_encryption_config.query_arg_profile_config != null ? [var.field_level_encryption_config.query_arg_profile_config] : []
    content {
      forward_when_query_arg_profile_is_unknown = query_arg_profile_config.value.forward_when_query_arg_profile_is_unknown

      dynamic "query_arg_profiles" {
        for_each = query_arg_profile_config.value.query_arg_profiles != null ? [query_arg_profile_config.value.query_arg_profiles] : []
        content {
          dynamic "items" {
            for_each = query_arg_profiles.value.items
            content {
              profile_id = items.value.profile_id
              query_arg  = items.value.query_arg
            }
          }
        }
      }
    }
  }

  dynamic "content_type_profile_config" {
    for_each = var.field_level_encryption_config != null && var.field_level_encryption_config.content_type_profile_config != null ? [var.field_level_encryption_config.content_type_profile_config] : []
    content {
      forward_when_content_type_is_unknown = content_type_profile_config.value.forward_when_content_type_is_unknown

      dynamic "content_type_profiles" {
        for_each = content_type_profile_config.value.content_type_profiles != null ? [content_type_profile_config.value.content_type_profiles] : []
        content {
          dynamic "items" {
            for_each = content_type_profiles.value.items
            content {
              profile_id   = items.value.profile_id
              content_type = items.value.content_type
              format       = items.value.format
            }
          }
        }
      }
    }
  }
}

# Enhanced CloudFront Real-time Log Configuration
resource "aws_cloudfront_realtime_log_config" "main" {
  count = var.enable_realtime_logs ? 1 : 0

  name   = var.realtime_logs_config.name
  sampling_rate = var.realtime_logs_config.sampling_rate
  fields = var.realtime_logs_config.fields

  dynamic "endpoint" {
    for_each = var.realtime_logs_config.end_points
    content {
      stream_type = endpoint.value.stream_type
      kinesis_stream_config {
        role_arn   = endpoint.value.kinesis_stream_config.role_arn
        stream_arn = endpoint.value.kinesis_stream_config.stream_arn
      }
    }
  }
}

# Enhanced CloudFront Function for security headers (optional)
resource "aws_cloudfront_function" "security_headers" {
  count   = var.enable_security_headers ? 1 : 0
  name    = local.security_headers_function_name
  runtime = var.security_headers_function_runtime
  comment = local.security_headers_function_comment
  publish = true
  code    = var.security_headers_function_code != null ? var.security_headers_function_code : file("${path.module}/functions/security-headers.js")
}

# Enhanced CloudFront Function association for security headers
resource "aws_cloudfront_function_association" "security_headers" {
  count = var.enable_security_headers ? 1 : 0

  function_arn   = aws_cloudfront_function.security_headers[0].arn
  event_type     = "viewer-response"
  distribution_id = aws_cloudfront_distribution.static_assets.id
}

# Enhanced S3 Bucket for CloudFront logs (if logging is enabled)
resource "aws_s3_bucket" "logs" {
  count  = var.logging_config != null ? 1 : 0
  bucket = local.logs_bucket_name

  tags = merge(local.enhanced_tags, var.logs_bucket_tags, {
    Name = local.logs_bucket_name
    Purpose = "CloudFront Logs"
  })
}

# Enhanced S3 Bucket versioning for logs
resource "aws_s3_bucket_versioning" "logs" {
  count  = var.logging_config != null ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id
  versioning_configuration {
    status = var.logs_bucket_versioning
  }
}

# Enhanced S3 Bucket server-side encryption for logs
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count  = var.logging_config != null ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.logs_bucket_encryption_algorithm
      kms_master_key_id = var.logs_bucket_encryption_algorithm == "aws:kms" ? (var.logs_bucket_kms_key_id != null ? var.logs_bucket_kms_key_id : aws_kms_key.cdn_encryption[0].arn) : null
    }
    bucket_key_enabled = true
  }
}

# Enhanced S3 Bucket lifecycle for logs
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count  = var.logging_config != null ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  dynamic "rule" {
    for_each = var.logs_bucket_lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "transition" {
        for_each = rule.value.transition
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition
        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }
}

# Enhanced CloudWatch Alarms for CDN monitoring
resource "aws_cloudwatch_metric_alarm" "cdn_alarms" {
  for_each = var.enable_cloudwatch_alarms ? var.cloudwatch_alarms : {}

  alarm_name          = "${var.distribution_name}-${each.key}"
  alarm_description   = lookup(each.value, "alarm_description", "CloudFront distribution alarm")
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = lookup(each.value, "evaluation_periods", 2)
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = lookup(each.value, "period", 300)
  statistic           = lookup(each.value, "statistic", "Sum")
  threshold           = each.value.threshold
  alarm_actions       = lookup(each.value, "alarm_actions", [])
  ok_actions          = lookup(each.value, "ok_actions", [])
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", [])
  treat_missing_data  = lookup(each.value, "treat_missing_data", "missing")
  unit                = lookup(each.value, "unit", null)
  extended_statistic  = lookup(each.value, "extended_statistic", null)
  datapoints_to_alarm = lookup(each.value, "datapoints_to_alarm", null)
  threshold_metric_id = lookup(each.value, "threshold_metric_id", null)

  dynamic "dimensions" {
    for_each = lookup(each.value, "dimensions", {})
    content {
      name  = dimensions.key
      value = dimensions.value
    }
  }

  tags = merge(local.enhanced_tags, lookup(each.value, "tags", {}))
}

# Enhanced Cost Optimization - Budget Alert
resource "aws_budgets_budget" "cdn_budget" {
  count = var.enable_cost_optimization && var.cost_optimization_config.enable_budget_alerts ? 1 : 0

  name              = "${var.distribution_name}-budget"
  budget_type       = "COST"
  limit_amount      = var.cost_optimization_config.budget_amount
  limit_unit        = var.cost_optimization_config.budget_currency
  time_period_start = "2023-01-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["admin@example.com"]
  }

  cost_filter {
    name = "TagKeyValue"
    values = ["Purpose$$CDN Distribution"]
  }
}

# Enhanced Resource Policies
resource "aws_s3_bucket_policy" "resource_policies" {
  for_each = var.enable_resource_policies ? var.resource_policies : {}

  bucket = aws_s3_bucket.static_assets.id
  policy = each.value.policy_document
} 