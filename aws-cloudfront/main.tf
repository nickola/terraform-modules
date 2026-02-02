locals {
  name_clean = replace(var.name, "/[^a-zA-Z0-9-_]/", "-")

  index_file = coalesce(var.index_file, "index.html")
  error_file = coalesce(var.error_file, "404.html")

  with_redirect = var.redirect != null
  with_redirect_as_function = local.with_redirect && var.redirect_as_function
  with_redirect_as_not_function = local.with_redirect && !var.redirect_as_function
}

# Identity
resource "aws_cloudfront_origin_access_identity" "cloudfront_access_identity" {
  comment = var.name
}

# S3
module "s3_bucket" {
  source = "../aws-s3"
  bucket = "cloudfront-static-${local.name_clean}"

  content_directory = var.content_directory
  website_redirect  = local.with_redirect_as_not_function ? var.redirect : null

  policy = local.with_redirect_as_not_function ? null : [
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
  count = (local.index_file != "" && var.index_html != null) ? 1 : 0

  bucket       = module.s3_bucket.bucket.id
  key          = local.index_file
  content      = var.index_html
  content_type = "text/html"
}

resource "aws_s3_object" "error_file" {
  count = (local.error_file != "" && var.error_html != null) ? 1 : 0

  bucket       = module.s3_bucket.bucket.id
  key          = local.error_file
  content      = var.error_html
  content_type = "text/html"
}

# Certificate
module "certificate" {
  source = "../aws-certificate"
  count  = var.domain != null ? 1 : 0

  domain = var.domain
}

resource "aws_cloudfront_function" "redirect" {
  count = local.with_redirect_as_function ? 1 : 0

  name    = "cloudfront-redirect-${local.name_clean}"
  runtime = "cloudfront-js-2.0"
  publish = true

  code = <<-DATA
    function handler(event) {
      return {
        statusCode: 301,
        headers: {
          "location": {
            "value": "https://${var.redirect}"
          }
        }
      };
    }
  DATA
}

# CloudFront
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  enabled         = true
  is_ipv6_enabled = true

  aliases = var.domain != null ? [var.domain] : []

  comment             = var.name
  price_class         = var.price_class
  default_root_object = !local.with_redirect ? local.index_file : null

  tags = {
    Name = var.name
  }

  dynamic "custom_error_response" {
    for_each = !local.with_redirect ? ["+"] : []

    content {
      error_code         = 403
      response_code      = 404
      response_page_path = "/${local.error_file}"
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
    domain_name = local.with_redirect_as_not_function ? module.s3_bucket.bucket_website_configuration.website_endpoint : module.s3_bucket.bucket.bucket_regional_domain_name

    dynamic "s3_origin_config" {
      for_each = local.with_redirect_as_not_function ? [] : ["+"]

      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_access_identity.cloudfront_access_identity_path
      }
    }

    dynamic "custom_origin_config" {
      for_each = local.with_redirect_as_not_function ? ["+"] : []

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

    dynamic "function_association" {
      for_each = local.with_redirect_as_function ? ["+"] : []

      content {
        event_type = "viewer-request"
        function_arn = aws_cloudfront_function.redirect[0].arn
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
