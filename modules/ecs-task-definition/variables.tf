variable "name_prefix" {
  description = "Prefix for all resource names, e.g. kaapi-staging"
  type        = string
}

variable "name" {
  description = "Short name of the task definition, e.g. backend-celery; family becomes <name_prefix>-<name>"
  type        = string
}

variable "launch_type" {
  description = "FARGATE or EC2"
  type        = string
  default     = "FARGATE"

  validation {
    condition     = contains(["FARGATE", "EC2"], var.launch_type)
    error_message = "launch_type must be FARGATE or EC2."
  }
}

variable "cpu_architecture" {
  description = "X86_64 or ARM64; must match how the images are built"
  type        = string
  default     = "X86_64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "cpu_architecture must be X86_64 or ARM64."
  }
}

variable "cpu" {
  description = "Task CPU units shared by all containers (1024 = 1 vCPU)"
  type        = number
}

variable "memory" {
  description = "Task memory in MiB shared by all containers"
  type        = number
}

variable "image_repository_urls" {
  description = "ECR repository URLs by short name (module.ecr.repository_urls)"
  type        = map(string)
}

variable "image_tag" {
  description = "Image tag for all containers; CI/CD normally deploys newer tags on top of this"
  type        = string
  default     = "latest"
}

variable "containers" {
  description = "Containers in the task, keyed by short name; container name becomes <name_prefix>-<key>"
  type = map(object({
    image_repository = string                 # key in image_repository_urls, e.g. backend
    command          = optional(list(string)) # overrides the image CMD
    container_port   = optional(number)       # omit for workers without a port
    app_protocol     = optional(string, "http")
    essential        = optional(bool, true)
    environment      = optional(map(string), {}) # overrides shared environment for this container
  }))

  validation {
    condition     = length(var.containers) > 0
    error_message = "A task definition needs at least one container."
  }
}

variable "environment" {
  description = "Non-secret environment variables shared by all containers, NAME => value"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secret environment variables shared by all containers, NAME => valueFrom: a Secrets Manager secret ARN, \"<secret-arn>:JSON_KEY::\" for one key of a JSON secret, or an SSM parameter ARN"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "How long to keep container logs in CloudWatch"
  type        = number
  default     = 30
}
