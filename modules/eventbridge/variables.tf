variable "name_prefix" {
  description = "Prefix for all resource names, e.g. kaapi-staging"
  type        = string
}

variable "tags" {
  description = "Extra tags to apply to resources in this module"
  type        = map(string)
  default     = {}
}
