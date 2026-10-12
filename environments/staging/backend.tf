# Remote state for the staging environment only.
# The bucket is created once via ../../bootstrap.
terraform {
  backend "s3" {
    bucket       = "kaapi-terraform-state"
    key          = "staging/terraform.tfstate"
    region       = "ap-south-1"
    profile      = "kaapi-staging"
    encrypt      = true
    use_lockfile = true
  }
}
