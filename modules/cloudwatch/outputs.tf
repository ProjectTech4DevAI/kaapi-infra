output "alarm_names" {
  description = "Names of all CloudWatch alarms created"
  value = concat(
    [for a in aws_cloudwatch_metric_alarm.ecs : a.alarm_name],
    [for a in aws_cloudwatch_metric_alarm.ec2 : a.alarm_name],
    [for a in aws_cloudwatch_metric_alarm.ec2_agent : a.alarm_name],
  )
}
