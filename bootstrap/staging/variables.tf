variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "aws_account_id" {
  type = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "state_bucket_name" {
  type = string
}
