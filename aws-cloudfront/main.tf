locals {
  s3_bucket_name = "cloudfront-static-${var.name}"
}

# Identity
resource "aws_cloudfront_origin_access_identity" "cloudfront_access_identity" {
  comment = var.name
}

# S3
module "s3_bucket" {
  source = "../aws-s3"
  bucket = local.s3_bucket_name

  content_directory = var.content_directory
  website_redirect  = var.redirect

  policy = var.redirect != null ? null : [
    {
      Sid      = "CloudfrontRead"
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = ["${module.s3_bucket.bucket.arn}/*"]
      Principal = {
        AWS = ["${aws_cloudfront_origin_access_identity.cloudfront_access_identity.iam_arn}"]
      }
    }
  ]
}

resource "aws_s3_object" "index_file" {
  count = (var.index_file != "" && var.index_html != null) ? 1 : 0

  tags = {
    Owner = "Terraform"
  }

  bucket       = module.s3_bucket.bucket.id
  key          = var.index_file
  content      = var.index_html
  content_type = "text/html"
}

resource "aws_s3_object" "error_file" {
  count = (var.error_file != "" && var.error_html != null) ? 1 : 0

  tags = {
    Owner = "Terraform"
  }

  bucket       = module.s3_bucket.bucket.id
  key          = var.error_file
  content      = var.error_html
  content_type = "text/html"
}

# Certificate
module "certificate" {
  source = "../aws-certificate"
  count  = var.domain != null ? 1 : 0

  domain = var.domain
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  enabled         = true
  is_ipv6_enabled = true

  aliases = var.domain != null ? [var.domain] : []

  comment             = var.name
  price_class         = var.price_class
  default_root_object = var.redirect == null ? var.index_file : null

  tags = {
    Name = var.name
  }

  dynamic "custom_error_response" {
    for_each = var.redirect == null ? ["+"] : []

    content {
      error_code         = 403
      response_code      = 404
      response_page_path = "/${var.error_file}"
    }
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
    for_each = var.domain == null ? ["+"] : []

    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.domain != null ? ["+"] : []

    content {
      ssl_support_method  = "sni-only"
      acm_certificate_arn = module.certificate[0].certificate.arn
    }
  }

  # Default origin / behavior
  origin {
    origin_id   = "default-s3"
    domain_name = var.redirect == null ? module.s3_bucket.bucket.bucket_regional_domain_name : module.s3_bucket.bucket_website_configuration.website_endpoint

    dynamic "s3_origin_config" {
      for_each = var.redirect == null ? ["+"] : []

      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_access_identity.cloudfront_access_identity_path
      }
    }

    dynamic "custom_origin_config" {
      for_each = var.redirect != null ? ["+"] : []

      content {
        http_port  = 80
        https_port = 443

        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
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
        headers      = lookup(ordered_cache_behavior.value, "forwarded_headers", null)

        cookies {
          forward = "none"
        }
      }
    }
  }
}

# Outputs
output "s3_bucket" {
  value = module.s3_bucket.bucket
}

output "cloudfront_access_identity" {
  value = aws_cloudfront_origin_access_identity.cloudfront_access_identity
}

output "status" {
  value = {
    aliases     = aws_cloudfront_distribution.cloudfront_distribution.aliases
    domain      = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    price_class = aws_cloudfront_distribution.cloudfront_distribution.price_class
  }
}
