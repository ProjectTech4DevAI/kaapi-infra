variable "name_prefix" {
  description = "Prefix for all resource names, e.g. kaapi-staging"
  type        = string
}

variable "repositories" {
  description = "Short names of the repositories to create, e.g. [\"backend\"]; full name becomes <name_prefix>-<name>"
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "MUTABLE lets a tag (e.g. latest) be pushed again; IMMUTABLE forbids overwriting a tag"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "max_image_count" {
  description = "How many most recent images to keep per repository"
  type        = number
  default     = 30
}

variable "untagged_image_expiry_days" {
  description = "Delete untagged images this many days after push"
  type        = number
  default     = 7
}
