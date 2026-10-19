data "aws_region" "current" {}

locals {
  name = "${var.name_prefix}-${var.name}"

  # "arn:aws:secretsmanager:<region>:<account>:secret:<name>[:JSON_KEY::]" -> secret ARN
  # without the JSON key part, so the execution role can read exactly these secrets
  secret_arns = distinct([
    for v in values(var.secrets) : join(":", slice(split(":", v), 0, min(7, length(split(":", v)))))
  ])
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${local.name}"
  retention_in_days = var.log_retention_days
}

data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Used by ECS itself: pull the image, write logs, read secrets at container start.
resource "aws_iam_role" "execution" {
  name               = "${local.name}-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_secrets" {
  count = length(var.secrets) > 0 ? 1 : 0

  name = "read-secrets"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "ssm:GetParameters"]
      Resource = local.secret_arns
    }]
  })
}

# Used by the application code inside the containers. Grant app permissions here later.
resource "aws_iam_role" "task" {
  name               = "${local.name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.name
  requires_compatibilities = [var.launch_type]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

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
