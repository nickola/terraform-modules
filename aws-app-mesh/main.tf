resource "aws_appmesh_mesh" "mesh" {
  name = "${var.name}-mesh"

  tags = {
    Name = "${var.name}-mesh"
  }

  spec {
    egress_filter {
      type = var.egress_filter
    }
  }
}

resource "aws_appmesh_virtual_node" "virtual_nodes" {
  for_each = var.virtual_nodes

  name      = each.key
  mesh_name = aws_appmesh_mesh.mesh.id

  spec {
    backend {
      virtual_service {
        virtual_service_name = each.key
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = each.value.cloud_map_namespace
        service_name   = each.value.cloud_map_service
      }
    }

    listener {
      port_mapping {
        port     = each.value.listener_port
        protocol = try(each.value.listener_protocol, "http")
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "virtual_services" {
  for_each = var.virtual_services

  name      = each.key
  mesh_name = aws_appmesh_mesh.mesh.id

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.virtual_nodes[each.value.virtual_node].name
      }
    }
  }
}
