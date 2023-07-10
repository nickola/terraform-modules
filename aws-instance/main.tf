module "security_group" {
  source   = "../aws-security-group"
  for_each = var.instances

  name   = "${var.name}-${each.key}"
  vpc_id = each.value.vpc_id

  ingress    = each.value.ingress
  egress_all = true
}

resource "aws_instance" "instance" {
  for_each = var.instances

  subnet_id     = each.value.subnet_id
  instance_type = each.value.instance_type
  ami           = each.value.ami
  key_name      = try(each.value.key_name, null)

  tags = {
    Name = "${var.name}-${each.key}"
  }

  vpc_security_group_ids = [
    module.security_group[each.key].id
  ]

  root_block_device {
    volume_size           = try(each.value.volume_size, 8)
    delete_on_termination = true
  }
}
