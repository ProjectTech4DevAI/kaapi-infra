variable "name_prefix" {
  description = "Prefix for all resource names, e.g. kaapi-staging"
  type        = string
}

variable "cidr_block" {
  description = "IPv4 CIDR block of the VPC, e.g. 10.0.0.0/16"
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR like 10.0.0.0/16."
  }
}

variable "tags" {
  description = "Extra tags for the VPC, on top of the provider default tags"
  type        = map(string)
  default     = {}
}
