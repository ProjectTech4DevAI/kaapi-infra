variable "project" {
  description = "Project name, used in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name (staging, prod, ...)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile (from ~/.aws/config) used to deploy this environment; null in CI, which uses OIDC credentials"
  type        = string
  default     = null
}

variable "aws_account_id" {
  description = "AWS account this environment must deploy into; Terraform refuses any other account"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "ecs_container_insights" {
  description = "Container Insights for the ECS cluster: enabled, enhanced or disabled"
  type        = string
  default     = "disabled"
}

variable "ecr_repositories" {
  description = "ECR repositories to create, by short name"
  type        = list(string)
}

variable "ecr_image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE image tags"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_max_image_count" {
  description = "How many most recent images to keep per repository"
  type        = number
  default     = 30
}

variable "ecs_launch_type" {
  description = "FARGATE or EC2 for all task definitions in this environment"
  type        = string
  default     = "FARGATE"
}

variable "ecs_log_retention_days" {
  description = "CloudWatch log retention for ECS containers"
  type        = number
  default     = 30
}

variable "ecs_task_definitions" {
  description = "ECS task definitions keyed by short name; see modules/ecs-task-definition for the fields"
  type = map(object({
    cpu              = number
    memory           = number
    cpu_architecture = optional(string, "X86_64")
    image_tag        = optional(string, "latest")
    containers = map(object({
      image_repository = string
      command          = optional(list(string))
      container_port   = optional(number)
      app_protocol     = optional(string, "http")
      essential        = optional(bool, true)
      environment      = optional(map(string), {})
    }))
    environment = optional(map(string), {})
    secrets = optional(map(object({
      secret = string
      key    = optional(string)
    })), {})
    execution_role_name = string
    task_role_name      = string
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for td in values(var.ecs_task_definitions) : concat(
        [for v in values(td.environment) : v != "REPLACE_ME"],
        [for c in values(td.containers) : [for v in values(c.environment) : v != "REPLACE_ME"]],
      )
    ]))
    error_message = "Some ECS environment variables are still \"REPLACE_ME\" in constants.tfvars; fill them in."
  }

  validation {
    condition = alltrue(flatten([
      for td in values(var.ecs_task_definitions) : [
        for s in values(td.secrets) : s.secret != "REPLACE_ME" && s.secret != ""
      ]
    ]))
    error_message = "Every ECS secret needs a real Secrets Manager secret name (not REPLACE_ME)."
  }

  validation {
    condition = alltrue(flatten([
      for td in values(var.ecs_task_definitions) : [
        for n in [td.execution_role_name, td.task_role_name] : n != "REPLACE_ME" && n != ""
      ]
    ]))
    error_message = "An ECS execution_role_name or task_role_name is still \"REPLACE_ME\" in constants.tfvars; use the real IAM role name."
  }
}

variable "ecs_private_environment" {
  description = "Env vars kept out of git (emails, usernames), task definition key => NAME => value; merged into that task definition's environment"
  type        = map(map(string))
  default     = {}

  validation {
    condition     = alltrue(flatten([for env in values(var.ecs_private_environment) : [for v in values(env) : v != "REPLACE_ME"]]))
    error_message = "Some values in ecs_private_environment are still \"REPLACE_ME\"."
  }
}

variable "vpc_id" {
  description = "Existing VPC the ECS tasks run in"
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "vpc_id must be a real VPC ID like vpc-0abc123 (not REPLACE_ME)."
  }
}

variable "ecs_subnet_ids" {
  description = "Existing subnets (in vpc_id) the ECS tasks run in"
  type        = list(string)

  validation {
    condition     = length(var.ecs_subnet_ids) > 0 && alltrue([for s in var.ecs_subnet_ids : can(regex("^subnet-[0-9a-f]+$", s))])
    error_message = "ecs_subnet_ids must be real subnet IDs like subnet-0abc123 (not REPLACE_ME)."
  }
}

variable "ecs_security_group_ids" {
  description = "Existing security groups attached to the ECS tasks"
  type        = list(string)

  validation {
    condition     = length(var.ecs_security_group_ids) > 0 && alltrue([for s in var.ecs_security_group_ids : can(regex("^sg-[0-9a-f]+$", s))])
    error_message = "ecs_security_group_ids must be real security group IDs like sg-0abc123 (not REPLACE_ME)."
  }
}

variable "ecs_assign_public_ip" {
  description = "Give tasks a public IP; true only for public subnets without a NAT gateway"
  type        = bool
  default     = false
}

variable "ecs_services" {
  description = "ECS services keyed by short name; each runs one entry of ecs_task_definitions"
  type = map(object({
    task_definition    = string # key in ecs_task_definitions
    min_tasks          = number
    max_tasks          = number
    cpu_target_percent = optional(number, 70) # null turns CPU auto scaling off
    load_balancer = optional(object({
      target_group_arn = string
      container        = string # container key in that task definition; must expose a port
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for svc in values(var.ecs_services) : contains(keys(var.ecs_task_definitions), svc.task_definition)])
    error_message = "Every ecs_services entry must use a task_definition that exists in ecs_task_definitions."
  }

  validation {
    condition     = alltrue([for svc in values(var.ecs_services) : svc.min_tasks >= 0 && svc.max_tasks >= svc.min_tasks])
    error_message = "For every ECS service, min_tasks must be >= 0 and max_tasks must be >= min_tasks."
  }

  validation {
    condition = alltrue([
      for svc in values(var.ecs_services) : svc.load_balancer == null ? true : (
        can(regex("^arn:aws:elasticloadbalancing:", svc.load_balancer.target_group_arn)) &&
        try(var.ecs_task_definitions[svc.task_definition].containers[svc.load_balancer.container].container_port != null, false)
      )
    ])
    error_message = "load_balancer needs a real target group ARN (not REPLACE_ME) and a container from that task definition that has a container_port."
  }
}

variable "monitoring_alert_topic_name" {
  description = "Short name of the SNS alert topic; full name becomes <project>-<environment>-<name>"
  type        = string
  default     = "monitoring-alerts"
}

variable "monitoring_alert_emails" {
  description = "Email addresses that receive monitoring alerts (each must confirm the AWS email)"
  type        = list(string)
  default     = []
}

variable "monitoring_ecs_cpu_threshold_percent" {
  description = "Alarm when an ECS service's average CPU stays above this %"
  type        = number
  default     = 80
}

variable "monitoring_ecs_memory_threshold_percent" {
  description = "Alarm when an ECS service's average memory stays above this %"
  type        = number
  default     = 80
}

variable "monitoring_ec2_instances" {
  description = "EC2 instances to alarm on, short key => { instance_id, cloudwatch_agent, disk_path }"
  type = map(object({
    instance_id      = string
    cloudwatch_agent = optional(bool, false) # true adds memory and disk alarms; the agent must be installed
    disk_path        = optional(string, "/")
  }))
  default = {}

  validation {
    condition     = alltrue([for inst in values(var.monitoring_ec2_instances) : can(regex("^i-[0-9a-f]{8,17}$", inst.instance_id))])
    error_message = "Each monitoring_ec2_instances entry needs a real instance_id like i-0123456789abcdef0 (not REPLACE_ME)."
  }
}

variable "monitoring_ec2_cpu_threshold_percent" {
  description = "Alarm when an EC2 instance's average CPU stays above this %"
  type        = number
  default     = 80
}

variable "monitoring_ec2_memory_threshold_percent" {
  description = "Alarm when an EC2 instance's memory use stays above this % (needs CloudWatch agent)"
  type        = number
  default     = 80
}

variable "monitoring_ec2_disk_threshold_percent" {
  description = "Alarm when an EC2 instance's disk use stays above this % (needs CloudWatch agent)"
  type        = number
  default     = 80
}
