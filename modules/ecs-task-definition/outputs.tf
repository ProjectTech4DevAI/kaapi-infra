output "task_definition_arn" {
  description = "ARN of the task definition revision managed by Terraform"
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "Task definition family; CI/CD registers new revisions under this name"
  value       = aws_ecs_task_definition.this.family
}

output "container_names" {
  description = "Container names by short key"
  value       = { for key, c in var.containers : key => "${var.name_prefix}-${key}" }
}

output "container_ports" {
  description = "Container ports by short key (only containers that expose one)"
  value       = { for key, c in var.containers : key => c.container_port if c.container_port != null }
}

output "execution_role_arn" {
  description = "ARN of the task execution role"
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "ARN of the task role used by the application"
  value       = aws_iam_role.task.arn
}

output "log_group_name" {
  description = "CloudWatch log group for the container logs"
  value       = aws_cloudwatch_log_group.this.name
}
