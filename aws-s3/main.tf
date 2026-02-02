# Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket

  tags = {
    Name = var.bucket
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  count  = var.public_read ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = (var.public_read || var.policy != null) ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      var.public_read ? [
        {
          Sid       = "PublicRead"
          Effect    = "Allow"
          Principal = "*"
          Action    = ["s3:GetObject"]
          Resource  = ["${aws_s3_bucket.bucket.arn}/*"]
        }
      ] : [],
      var.policy != null ? var.policy : []
    )
  })
}

# Website
resource "aws_s3_bucket_website_configuration" "website" {
  count  = var.website_redirect != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  redirect_all_requests_to {
    host_name = var.website_redirect
    protocol  = var.website_redirect_protocol
  }
}

# Content
locals {
  content_exclude = flatten([
    for pattern in setunion(coalesce(var.content_directory_exclude_always, []), coalesce(var.content_directory_exclude, [])) : [
      "^${replace(replace(replace(replace(pattern, ".", "\\."), "**/", "[__[DOUBLE_STAR]__]"), "*", "[^/]*"), "[__[DOUBLE_STAR]__]", ".*")}$",
      "^${replace(replace(replace(replace(pattern, ".", "\\."), "**/", "[__[DOUBLE_STAR]__]"), "*", "[^/]*"), "[__[DOUBLE_STAR]__]", ".*")}/.*$"
    ]
  ])

  content_files = var.content_directory == null ? {} : {
    for file_path in fileset(var.content_directory, "**") : file_path => {
      full_path    = "${var.content_directory}/${file_path}"
      md5          = filemd5("${var.content_directory}/${file_path}")
      content_type = lookup(var.content_types, try(lower(element(regexall("\\.[^.]+$", file_path), 0)), ""), var.default_content_type)
    } if !anytrue([for regex in local.content_exclude : can(regex(regex, file_path))])
  }
}

resource "aws_s3_object" "content_files" {
  for_each = local.content_files
  bucket   = aws_s3_bucket.bucket.id

  key          = each.key
  source       = each.value.full_path
  content_type = each.value.content_type
  etag         = each.value.md5
}

# Outputs
output "bucket" {
  value = aws_s3_bucket.bucket
}

output "bucket_website_configuration" {
  value = var.website_redirect != null ? aws_s3_bucket_website_configuration.website[0] : null
}

output "status" {
  value = {
    bucket_arn         = aws_s3_bucket.bucket.arn
    bucket_domain      = aws_s3_bucket.bucket.bucket_domain_name
    bucket_public_read = var.public_read
  }
}
