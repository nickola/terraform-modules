resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain
  validation_method = var.validation_method

  lifecycle {
    create_before_destroy = true
  }
}

output "certificate" {
  value = aws_acm_certificate.certificate
}

output "status" {
  value = {
    certificate_arn         = aws_acm_certificate.certificate.arn
    certificate_domain_name = aws_acm_certificate.certificate.domain_name
  }
}
