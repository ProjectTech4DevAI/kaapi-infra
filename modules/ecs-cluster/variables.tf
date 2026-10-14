variable "name_prefix" {
  description = "Prefix for all resource names, e.g. kaapi-staging"
  type        = string
}

variable "tags" {
  description = "Extra tags to apply to resources in this module"
  type        = map(string)
  default     = {}
}

variable "container_insights" {
  description = "CloudWatch Container Insights for the cluster: enabled, enhanced or disabled (adds CloudWatch cost)"
  type        = string
  default     = "disabled"

  validation {
    condition     = contains(["enabled", "enhanced", "disabled"], var.container_insights)
    error_message = "container_insights must be one of: enabled, enhanced, disabled."
  }
}
