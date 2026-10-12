# All prod-specific values live here.
project     = "kaapi"
environment = "prod"
aws_region  = "ap-south-1"
vpc_cidr    = "10.20.0.0/16"

# AWS account guard: Terraform will refuse to run against any other account.
aws_profile    = "kaapi-prod"
aws_account_id = "REPLACE_WITH_PROD_ACCOUNT_ID" # 12 digits, from: aws sts get-caller-identity
