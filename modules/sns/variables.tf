variable "name_prefix" {
  description = "Prefix for all resource names, e.g. kaapi-staging"
  type        = string
}

variable "topic_name" {
  description = "Short topic name; full name becomes <name_prefix>-<topic_name>"
  type        = string
}

variable "email_addresses" {
  description = "Email addresses subscribed to the topic; kept sensitive so they stay out of plan output"
  type        = list(string)
  default     = []
  sensitive   = true

  validation {
    condition     = alltrue([for e in var.email_addresses : can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", e))])
    error_message = "Every entry in email_addresses must be a valid email address."
  }
}
