# One ECS task definition (one or more containers) and its CloudWatch log group.
# IAM roles and secrets are not created here: existing ones are referenced by ARN.
# Nothing runs until an ECS service uses this task definition.

data "aws_region" "current" {}

locals {
  name = "${var.name_prefix}-${var.name}"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${local.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.name
  requires_compatibilities = [var.launch_type]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.cpu_architecture
  }

  container_definitions = jsonencode([
    for key, c in var.containers : {
      name      = "${var.name_prefix}-${key}"
      image     = "${var.image_repository_urls[c.image_repository]}:${var.image_tag}"
      essential = c.essential
      command   = c.command

      portMappings = [
        for port in(c.container_port == null ? [] : [c.container_port]) : {
          name          = "${var.name_prefix}-${key}-${port}-tcp"
          containerPort = port
          hostPort      = port
          protocol      = "tcp"
          appProtocol   = c.app_protocol
        }
      ]

      # Shared env vars, with per-container values winning on conflict
      environment = [for k, v in merge(var.environment, c.environment) : { name = k, value = v }]

      secrets = [for k, v in var.secrets : { name = k, valueFrom = v }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = key
        }
      }
    }
  ])
}
