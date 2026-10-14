# Remote state for the prod environment only.
# bucket, region and profile come from .env.prod via "make init ENV=prod"
# (passed as -backend-config, since backend blocks cannot read variables).
terraform {
  backend "s3" {
    key          = "prod/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
