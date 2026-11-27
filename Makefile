# Usage: make plan ENV=staging
# Values are read from .env.$(ENV) (see .env.example), $(DIR)/constants.tfvars (committed)
# and $(DIR)/terraform.tfvars (private values only, never committed).
ENV ?= staging
DIR := environments/$(ENV)
BOOTSTRAP_DIR := bootstrap/$(ENV)
ENV_FILE := .env.$(ENV)

-include $(ENV_FILE)

export AWS_PROFILE
export TF_VAR_aws_profile        := $(AWS_PROFILE)
export TF_VAR_aws_region         := $(AWS_REGION)
export TF_VAR_state_bucket_name  := $(TF_STATE_BUCKET)

AWS_ACCOUNT_ID := $(shell sed -n 's/^aws_account_id *= *"\([^"]*\)".*/\1/p' $(DIR)/terraform.tfvars 2>/dev/null)

BACKEND_CONFIG := \
	-backend-config="bucket=$(TF_STATE_BUCKET)" \
	-backend-config="region=$(AWS_REGION)" \
	-backend-config="profile=$(AWS_PROFILE)"

.PHONY: check-env bootstrap init plan generate apply destroy fmt validate

check-env:
	@test -f $(ENV_FILE) || { echo "$(ENV_FILE) not found. Run: cp .env.example $(ENV_FILE) and fill it in."; exit 1; }
	@test -f $(DIR)/terraform.tfvars || { echo "$(DIR)/terraform.tfvars not found. Run: cp $(DIR)/terraform.tfvars.example $(DIR)/terraform.tfvars and fill it in."; exit 1; }
	@test -n "$(AWS_ACCOUNT_ID)" || { echo "aws_account_id is missing in $(DIR)/terraform.tfvars"; exit 1; }
	@test -n "$(AWS_PROFILE)" || { echo "AWS_PROFILE is empty in $(ENV_FILE)"; exit 1; }
	@test -n "$(AWS_REGION)" || { echo "AWS_REGION is empty in $(ENV_FILE)"; exit 1; }
	@test -n "$(TF_STATE_BUCKET)" || { echo "TF_STATE_BUCKET is empty in $(ENV_FILE)"; exit 1; }

# One-time per AWS account: create the state bucket for $(ENV)
bootstrap: check-env
	terraform -chdir=$(BOOTSTRAP_DIR) init
	TF_VAR_aws_account_id=$(AWS_ACCOUNT_ID) terraform -chdir=$(BOOTSTRAP_DIR) apply

init: check-env
	terraform -chdir=$(DIR) init -reconfigure $(BACKEND_CONFIG)

plan: check-env
	terraform -chdir=$(DIR) plan -var-file=constants.tfvars -out=$(ENV).tfplan

# Writes HCL for the resources in $(DIR)/imports.tf to $(DIR)/generated.tf (plan only, changes nothing)
generate: check-env
	@test ! -f $(DIR)/generated.tf || { echo "$(DIR)/generated.tf already exists; move or delete it first."; exit 1; }
	terraform -chdir=$(DIR) plan -var-file=constants.tfvars -generate-config-out=generated.tf

apply: check-env
	terraform -chdir=$(DIR) apply $(ENV).tfplan

destroy: check-env
	terraform -chdir=$(DIR) destroy -var-file=constants.tfvars

fmt:
	terraform fmt -recursive

validate: check-env
	terraform -chdir=$(DIR) validate
