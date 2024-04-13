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
  count  = var.public_read ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  policy = <<-DATA
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "PublicRead",
          "Effect": "Allow",
          "Principal": "*",
          "Action": ["s3:GetObject"],
          "Resource": [
            "${aws_s3_bucket.bucket.arn}/*"
          ]
        }
      ]
    }
  DATA
}

output "bucket" {
  value = aws_s3_bucket.bucket
}

output "status" {
  value = {
    bucket_arn         = aws_s3_bucket.bucket.arn
    bucket_domain      = aws_s3_bucket.bucket.bucket_domain_name
    bucket_public_read = var.public_read
  }
}
