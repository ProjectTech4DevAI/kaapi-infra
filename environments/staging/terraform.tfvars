# All staging-specific values live here.
project     = "kaapi"
environment = "staging"
aws_region  = "ap-south-1"
vpc_cidr    = "10.10.0.0/16"

# AWS account guard: Terraform will refuse to run against any other account.
aws_profile    = "kaapi-staging"
aws_account_id = "REPLACE_WITH_STAGING_ACCOUNT_ID" # 12 digits, from: aws sts get-caller-identity
