# Remote state for the staging environment only.
# bucket, region and profile come from .env.staging via "make init ENV=staging"
# (passed as -backend-config, since backend blocks cannot read variables).
terraform {
  backend "s3" {
    key          = "staging/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
