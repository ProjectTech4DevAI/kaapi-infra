locals {
  name = "${var.name_prefix}-${var.name}"
}

data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)

  id = each.value
}

resource "aws_ecs_service" "this" {
  name                   = local.name
  cluster                = var.cluster_arn
  task_definition        = var.task_definition_arn
  desired_count          = var.min_tasks
  launch_type            = var.launch_type
  enable_execute_command = var.enable_execute_command

  # Roll back automatically if new tasks keep failing to start
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer == null ? [] : [var.load_balancer]

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  health_check_grace_period_seconds = var.load_balancer == null ? null : var.health_check_grace_period_seconds

  lifecycle {
    # Auto scaling owns the running task count after the first apply
    ignore_changes = [desired_count]

    precondition {
      condition     = alltrue([for s in data.aws_subnet.selected : s.vpc_id == var.vpc_id])
      error_message = "All subnet_ids must belong to vpc_id ${var.vpc_id}."
    }
  }
}

resource "aws_appautoscaling_target" "this" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_tasks
  max_capacity       = var.max_tasks
}

# Adds tasks when average CPU goes above the target and removes them when it drops
resource "aws_appautoscaling_policy" "cpu" {
  count = var.cpu_target_percent == null ? 0 : 1

  name               = "${local.name}-cpu"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.this.service_namespace
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = var.cpu_target_percent
    scale_in_cooldown  = 300
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
