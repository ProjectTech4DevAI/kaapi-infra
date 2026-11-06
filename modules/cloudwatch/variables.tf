variable "name_prefix" {
  description = "Prefix for all resource names, e.g. kaapi-staging"
  type        = string
}

variable "alarm_topic_arn" {
  description = "SNS topic ARN that alarms notify"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster the services run in"
  type        = string
}

variable "ecs_service_names" {
  description = "ECS services to alarm on, short key => full service name"
  type        = map(string)
  default     = {}
}

variable "ecs_cpu_threshold_percent" {
  description = "Alarm when average service CPU stays above this %"
  type        = number
  default     = 80
}

variable "ecs_memory_threshold_percent" {
  description = "Alarm when average service memory stays above this %"
  type        = number
  default     = 80
}

variable "period_seconds" {
  description = "Length of one evaluation period in seconds"
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "How many consecutive periods must breach before alarming"
  type        = number
  default     = 2
}

variable "ec2_instances" {
  description = "EC2 instances to alarm on, short key => instance details"
  type = map(object({
    instance_id      = string
    cloudwatch_agent = optional(bool, false) # true adds memory and disk alarms
    disk_path        = optional(string, "/")
  }))
  default = {}

  validation {
    condition     = alltrue([for inst in values(var.ec2_instances) : can(regex("^i-[0-9a-f]{8,17}$", inst.instance_id))])
    error_message = "Each ec2_instances entry needs a real instance_id like i-0123456789abcdef0."
  }
}

variable "ec2_cpu_threshold_percent" {
  description = "Alarm when an EC2 instance's average CPU stays above this %"
  type        = number
  default     = 80
}

variable "ec2_memory_threshold_percent" {
  description = "Alarm when an EC2 instance's memory use stays above this % (needs CloudWatch agent)"
  type        = number
  default     = 80
}

variable "ec2_disk_threshold_percent" {
  description = "Alarm when an EC2 instance's disk use stays above this % (needs CloudWatch agent)"
  type        = number
  default     = 80
}
