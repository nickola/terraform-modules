resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-ecs"

  tags = {
    Name = "${var.name}-ecs"
  }

  setting {
    name  = "containerInsights"
    value = var.container_insights == true ? "enabled" : "disabled"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  for_each = var.task_definitions
  name     = "${var.name}-ecs-task-execution-role-${each.key}"

  tags = {
    Name = "${var.name}-ecs-task-execution-role-${each.key}"
  }

  assume_role_policy = <<-DATA
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "ecs-tasks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  DATA
}

resource "aws_iam_policy" "ecs_session_manager_policy" {
  name = "${var.name}-ecs-session-manager-policy"

  tags = {
    Name = "${var.name}-ecs-session-manager-policy"
  }

  policy = <<-DATA
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": "*"
        }
      ]
    }
  DATA
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment_task_execution_role" {
  for_each = var.task_definitions

  role       = aws_iam_role.ecs_task_execution_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment_app_mesh_envoy_access" {
  for_each = var.task_definitions

  role       = aws_iam_role.ecs_task_execution_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment_session_manager_policy" {
  for_each = var.task_definitions

  role       = aws_iam_role.ecs_task_execution_role[each.key].name
  policy_arn = aws_iam_policy.ecs_session_manager_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment_extra" {
  for_each = { for key, value in var.task_definitions : key => value if contains(keys(value), "extra_policy_arn") }

  role       = aws_iam_role.ecs_task_execution_role[each.key].name
  policy_arn = each.value.extra_policy_arn
}

resource "aws_ecs_task_definition" "ecs_task_definitions" {
  for_each = var.task_definitions

  family                   = each.key
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  cpu                      = each.value.cpu
  memory                   = each.value.memory

  task_role_arn         = aws_iam_role.ecs_task_execution_role[each.key].arn
  execution_role_arn    = aws_iam_role.ecs_task_execution_role[each.key].arn
  container_definitions = each.value.container_definitions

  tags = {
    Name = "${var.name}-ecs-task-definition-${each.key}"
  }

  dynamic "proxy_configuration" {
    for_each = contains(keys(each.value), "app_mesh") ? [each.value.app_mesh] : []

    content {
      type           = "APPMESH"
      container_name = proxy_configuration.value.container_name
      properties = {
        AppPorts         = proxy_configuration.value.container_port
        EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
        IgnoredUID       = "1337"
        ProxyEgressPort  = 15001
        ProxyIngressPort = 15000
      }
    }
  }
}

module "security_group" {
  source   = "../aws-security-group"
  for_each = var.services

  name   = "${var.name}-ecs-${each.key}"
  vpc_id = each.value.vpc_id

  ingress    = each.value.ingress
  egress_all = true
}

resource "aws_ecs_service" "ecs_services" {
  for_each = var.services

  name            = each.key
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = "${aws_ecs_task_definition.ecs_task_definitions[each.value.task_definition].id}:${aws_ecs_task_definition.ecs_task_definitions[each.value.task_definition].revision}"

  launch_type            = each.value.launch_type
  desired_count          = try(each.value.desired_count, 1)
  force_new_deployment   = try(each.value.force_new_deployment, true)
  enable_execute_command = try(each.value.enable_execute_command, false)

  tags = {
    Name = "${var.name}-ecs-services-${each.key}"
  }

  network_configuration {
    assign_public_ip = try(each.value.assign_public_ip, false)
    security_groups  = [module.security_group[each.key].id]
    subnets          = each.value.subnet_ids
  }

  dynamic "load_balancer" {
    for_each = contains(keys(each.value), "load_balancer") ? [each.value.load_balancer] : []

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  service_registries {
    registry_arn = each.value.service_registry_arn
  }
}
