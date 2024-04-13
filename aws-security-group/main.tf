resource "aws_security_group" "security_group" {
  name   = "${var.name}-security-group"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-security-group"
  }

  dynamic "ingress" {
    for_each = var.ingress != null ? toset(var.ingress) : []

    content {
      protocol    = ingress.key.protocol
      from_port   = ingress.key.from_port
      to_port     = ingress.key.to_port
      cidr_blocks = ingress.key.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_all ? [1] : []

    content {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

# Outputs
output "id" {
  value = aws_security_group.security_group.id
}
