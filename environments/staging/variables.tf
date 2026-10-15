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
  description = "AWS CLI profile (from ~/.aws/config) used to deploy this environment"
  type        = string
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
