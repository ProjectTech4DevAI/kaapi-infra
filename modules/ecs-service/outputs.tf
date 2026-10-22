output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.this.id
}

output "min_tasks" {
  description = "Minimum running tasks"
  value       = aws_appautoscaling_target.this.min_capacity
}

output "max_tasks" {
  description = "Maximum running tasks"
  value       = aws_appautoscaling_target.this.max_capacity
}
