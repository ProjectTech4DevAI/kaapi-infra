variable "name_prefix" {
  description = "Prefix for all resource names, e.g. kaapi-staging"
  type        = string
}

variable "name" {
  description = "Short name of the service; full name becomes <name_prefix>-<name>"
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster to run in"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster (used by auto scaling)"
  type        = string
}

variable "task_definition_arn" {
  description = "Task definition revision to run"
  type        = string
}

variable "launch_type" {
  description = "FARGATE or EC2; must match the task definition"
  type        = string
  default     = "FARGATE"
}

variable "vpc_id" {
  description = "VPC the subnets must belong to"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets the tasks run in"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to the tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "true for public subnets without NAT; false for private subnets"
  type        = bool
  default     = false
}

variable "min_tasks" {
  description = "Minimum number of running tasks (also the count on first deploy)"
  type        = number
}

variable "max_tasks" {
  description = "Maximum number of running tasks auto scaling may reach"
  type        = number

  validation {
    condition     = var.max_tasks >= var.min_tasks && var.min_tasks >= 0
    error_message = "max_tasks must be >= min_tasks, and min_tasks must be >= 0."
  }
}

variable "cpu_target_percent" {
  description = "Average CPU % auto scaling aims for; null disables CPU scaling (count stays at min_tasks)"
  type        = number
  default     = 70
}

variable "load_balancer" {
  description = "ALB target group to register the container in; null for services without traffic (workers)"
  type = object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  })
  default = null
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore ALB health checks after a task starts"
  type        = number
  default     = 60
}

variable "enable_execute_command" {
  description = "Allow `aws ecs execute-command` into running containers"
  type        = bool
  default     = false
}
