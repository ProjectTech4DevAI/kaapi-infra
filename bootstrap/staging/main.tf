# One-time setup for the staging AWS account: creates the S3 bucket that holds
# staging's Terraform state.
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region              = var.aws_region
  profile             = var.aws_profile
  allowed_account_ids = [var.aws_account_id]
}

module "state_bucket" {
  source = "../state-bucket"

  bucket_name = var.state_bucket_name
}

output "state_bucket" {
  value = module.state_bucket.bucket_name
}
