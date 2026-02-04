locals {
  content_type = lookup(var.content_types, try(lower(element(regexall("\\.[^.]+$", var.file), 0)), ""), var.default_content_type)
}

# Outputs
output "content_type" {
  value = local.content_type
}
