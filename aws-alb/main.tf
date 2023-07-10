module "security_group" {
  source = "../aws-security-group"

  name   = "${var.name}-alb"
  vpc_id = var.vpc_id

  ingress    = var.ingress
  egress_all = true
}

resource "aws_lb" "alb" {
  name = "${var.name}-alb"

  load_balancer_type = "application"
  internal           = var.internal

  subnets         = var.subnet_ids
  security_groups = [module.security_group.id]

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_alb_target_group" "alb_target" {
  name        = "${var.name}-alb-target"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = 80
  target_type = "ip"

  tags = {
    Name = "${var.name}-alb-target"
  }

  health_check {
    interval            = "30"
    timeout             = "15"
    unhealthy_threshold = "2"
    healthy_threshold   = "3"
    protocol            = "HTTP"
    matcher             = "200"
    path                = var.health_check_path
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.id
  protocol          = "HTTP"
  port              = 80

  tags = {
    Name = "${var.name}-alb-listener"
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target.id
  }
}

# Outputs
output "alb" {
  value = aws_lb.alb
}

output "alb_target_group" {
  value = aws_alb_target_group.alb_target
}
