# Remote state for the prod environment only.
# The bucket is created once via ../../bootstrap.
terraform {
  backend "s3" {
    bucket       = "kaapi-terraform-state"
    key          = "prod/terraform.tfstate"
    region       = "ap-south-1"
    profile      = "kaapi-prod"
    encrypt      = true
    use_lockfile = true
  }
}
