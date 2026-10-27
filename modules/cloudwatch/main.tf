locals {
  # One alarm per service per metric, e.g. "backend-celery-cpu"
  ecs_alarms = merge([
    for key, service_name in var.ecs_service_names : {
      "${key}-cpu" = {
        service_name = service_name
        metric_name  = "CPUUtilization"
        threshold    = var.ecs_cpu_threshold_percent
        label        = "CPU"
      }
      "${key}-memory" = {
        service_name = service_name
        metric_name  = "MemoryUtilization"
        threshold    = var.ecs_memory_threshold_percent
        label        = "memory"
      }
    }
  ]...)
}

resource "aws_cloudwatch_metric_alarm" "ecs" {
  for_each = local.ecs_alarms

  alarm_name        = "${var.name_prefix}-${each.key}-high"
  alarm_description = "Average ${each.value.label} of ECS service ${each.value.service_name} is above ${each.value.threshold}%"

  namespace   = "AWS/ECS"
  metric_name = each.value.metric_name
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = each.value.service_name
  }

  statistic           = "Average"
  period              = var.period_seconds
  evaluation_periods  = var.evaluation_periods
  comparison_operator = "GreaterThanThreshold"
  threshold           = each.value.threshold

  treat_missing_data = "notBreaching"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
}

# CloudWatch alarms for EC2 instances. CPU and status checks come from AWS
# automatically; memory and disk only exist when the CloudWatch agent runs on
# the instance, so those alarms are created only when cloudwatch_agent = true.
locals {
  ec2_alarms = merge([
    for key, inst in var.ec2_instances : {
      "${key}-cpu-high" = {
        instance_id = inst.instance_id
        metric_name = "CPUUtilization"
        statistic   = "Average"
        threshold   = var.ec2_cpu_threshold_percent
        description = "Average CPU of EC2 instance ${inst.instance_id} (${key}) is above ${var.ec2_cpu_threshold_percent}%"
      }
      "${key}-status-check-failed" = {
        instance_id = inst.instance_id
        metric_name = "StatusCheckFailed"
        statistic   = "Maximum"
        threshold   = 0
        description = "EC2 instance ${inst.instance_id} (${key}) is failing its status checks"
      }
    }
  ]...)

  # Agent metrics carry extra dimensions (ImageId, InstanceType, device, ...)
  # that differ per setup, so they are matched with a Metrics Insights query
  # filtered on InstanceId instead of an exact dimension set.
  ec2_agent_alarms = merge([
    for key, inst in var.ec2_instances : {
      "${key}-memory-high" = {
        query       = "SELECT MAX(mem_used_percent) FROM CWAgent WHERE InstanceId = '${inst.instance_id}'"
        threshold   = var.ec2_memory_threshold_percent
        description = "Memory used on EC2 instance ${inst.instance_id} (${key}) is above ${var.ec2_memory_threshold_percent}%"
      }
      "${key}-disk-high" = {
        query       = "SELECT MAX(disk_used_percent) FROM CWAgent WHERE InstanceId = '${inst.instance_id}' AND path = '${inst.disk_path}'"
        threshold   = var.ec2_disk_threshold_percent
        description = "Disk ${inst.disk_path} on EC2 instance ${inst.instance_id} (${key}) is above ${var.ec2_disk_threshold_percent}% full"
      }
    } if inst.cloudwatch_agent
  ]...)
}

resource "aws_cloudwatch_metric_alarm" "ec2" {
  for_each = local.ec2_alarms

  alarm_name        = "${var.name_prefix}-ec2-${each.key}"
  alarm_description = each.value.description

  namespace   = "AWS/EC2"
  metric_name = each.value.metric_name
  dimensions = {
    InstanceId = each.value.instance_id
  }

  statistic           = each.value.statistic
  period              = var.period_seconds
  evaluation_periods  = var.evaluation_periods
  comparison_operator = "GreaterThanThreshold"
  threshold           = each.value.threshold

  # No data (e.g. instance stopped) is not treated as a problem
  treat_missing_data = "notBreaching"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_agent" {
  for_each = local.ec2_agent_alarms

  alarm_name        = "${var.name_prefix}-ec2-${each.key}"
  alarm_description = each.value.description

  metric_query {
    id          = "m1"
    expression  = each.value.query
    period      = var.period_seconds
    return_data = true
  }

  evaluation_periods  = var.evaluation_periods
  comparison_operator = "GreaterThanThreshold"
  threshold           = each.value.threshold

  treat_missing_data = "notBreaching"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
}
