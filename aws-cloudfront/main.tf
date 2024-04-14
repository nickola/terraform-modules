# S3 access
resource "aws_cloudfront_origin_access_identity" "cloudfront_access_identity" {
  comment = var.description
}

# S3 files
data "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_id
}

resource "aws_s3_object" "index_file" {
  count = (var.s3_bucket_id != "" && var.index_file != "" && var.index_html != "") ? 1 : 0

  bucket       = var.s3_bucket_id
  key          = var.index_file
  content      = var.index_html
  content_type = "text/html"
}

resource "aws_s3_object" "error_file" {
  count = (var.s3_bucket_id != "" && var.error_file != "" && var.error_html != "") ? 1 : 0

  bucket       = var.s3_bucket_id
  key          = var.error_file
  content      = var.error_html
  content_type = "text/html"
}

# Certificate
resource "aws_acm_certificate" "certificate" {
  count = var.domain_alias != null ? 1 : 0

  domain_name       = var.domain_alias
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# CloudFront
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  enabled         = true
  is_ipv6_enabled = true

  aliases = var.domain_alias != null ? [var.domain_alias] : []

  comment             = var.description
  price_class         = var.price_class
  default_root_object = var.index_file

  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/${var.error_file}"
  }

  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction != null ? "whitelist" : "none"
      locations        = var.geo_restriction != null ? var.geo_restriction : []
    }
  }

  # Certificate
  dynamic "viewer_certificate" {
    for_each = var.domain_alias == null ? ["+"] : []

    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.domain_alias != null ? ["+"] : []

    content {
      ssl_support_method  = "sni-only"
      acm_certificate_arn = aws_acm_certificate.certificate[0].arn
    }
  }

  # Default origin / behavior
  origin {
    origin_id   = "default-s3"
    domain_name = data.aws_s3_bucket.bucket.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = "default-s3"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = var.allowed_methods
    cached_methods         = coalesce(var.cached_methods, var.allowed_methods)
    compress               = true

    default_ttl = var.ttl
    min_ttl     = var.ttl_min != null ? var.ttl_min : var.ttl
    max_ttl     = var.ttl_max != null ? var.ttl_max : var.ttl

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  # Rules (origins / behaviors)
  dynamic "origin" {
    for_each = var.rules != null ? var.rules : []

    content {
      origin_id   = origin.value.url
      domain_name = replace(replace(origin.value.lambda_url, "https://", ""), "/", "")

      custom_origin_config {
        http_port  = 80
        https_port = 443

        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.rules != null ? var.rules : []

    content {
      target_origin_id = ordered_cache_behavior.value.url
      path_pattern     = ordered_cache_behavior.value.url

      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = coalesce(lookup(ordered_cache_behavior.value, "allowed_methods", null), var.allowed_methods)
      cached_methods         = coalesce(lookup(ordered_cache_behavior.value, "cached_methods", null), coalesce(lookup(ordered_cache_behavior.value, "allowed_methods", null), coalesce(var.cached_methods, var.allowed_methods)))
      compress               = true

      default_ttl = coalesce(lookup(ordered_cache_behavior.value, "ttl", null), var.ttl)
      min_ttl     = coalesce(lookup(ordered_cache_behavior.value, "ttl_min", null), coalesce(lookup(ordered_cache_behavior.value, "ttl", null), var.ttl_min != null ? var.ttl_min : var.ttl))
      max_ttl     = coalesce(lookup(ordered_cache_behavior.value, "ttl_max", null), coalesce(lookup(ordered_cache_behavior.value, "ttl", null), var.ttl_max != null ? var.ttl_max : var.ttl))

      forwarded_values {
        query_string = true

        cookies {
          forward = "none"
        }
      }
    }
  }
}

# Outputs
output "access_identity" {
  value = aws_cloudfront_origin_access_identity.cloudfront_access_identity.iam_arn
}

output "status" {
  value = {
    aliases     = aws_cloudfront_distribution.cloudfront_distribution.aliases
    domain      = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    price_class = aws_cloudfront_distribution.cloudfront_distribution.price_class
  }
}
