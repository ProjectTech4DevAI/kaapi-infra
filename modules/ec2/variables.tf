variable "name_prefix" {
  description = "Prefix for all resource names, e.g. kaapi-staging"
  type        = string
}

variable "instances" {
  description = "EC2 instances, short key => settings; the Name tag becomes <name_prefix>-<name>"
  type = map(object({
    name                 = string
    instance_type        = string
    iam_instance_profile = optional(string)
    tags                 = optional(map(string), {}) # extra tags already on the instance, besides Name
  }))
  default = {}
}

variable "instance_ids" {
  description = "Map of short key => existing instance ID (i-...), one for every key in instances"
  type        = map(string)
  default     = {}
}
