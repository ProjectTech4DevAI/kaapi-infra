# Usage: make plan ENV=staging
ENV ?= staging
DIR := environments/$(ENV)

.PHONY: init plan apply destroy fmt validate

init:
	terraform -chdir=$(DIR) init

plan:
	terraform -chdir=$(DIR) plan -out=$(ENV).tfplan

apply:
	terraform -chdir=$(DIR) apply $(ENV).tfplan

destroy:
	terraform -chdir=$(DIR) destroy

fmt:
	terraform fmt -recursive

validate:
	terraform -chdir=$(DIR) validate
