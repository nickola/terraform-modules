resource "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "record" {
  for_each = var.records != null ? { for record in var.records : "${record.type}-${coalesce(record.name, "root")}" => record } : {}

  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name != null ? each.value.name : ""
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.values
}
