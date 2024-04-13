resource "aws_service_discovery_private_dns_namespace" "service_discovery" {
  name        = var.domain
  vpc         = var.vpc_id
  description = var.description

  tags = {
    Name = "${var.name}-service-discovery"
  }
}

resource "aws_service_discovery_service" "services" {
  for_each = { for service in var.services : service => service }

  name = each.key

  tags = {
    Name = "${var.name}-service-${each.key}"
  }

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.service_discovery.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 30
    }
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}

# Outputs
output "namespace" {
  value = aws_service_discovery_private_dns_namespace.service_discovery
}

output "services" {
  value = aws_service_discovery_service.services
}
