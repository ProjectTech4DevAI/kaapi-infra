# Wires the shared modules together for the staging environment.

module "kms" {
  source = "../../modules/kms"

  name_prefix = local.name_prefix
}

module "iam" {
  source = "../../modules/iam"

  name_prefix = local.name_prefix
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix = local.name_prefix
}

module "ecr" {
  source = "../../modules/ecr"

  name_prefix = local.name_prefix
}

module "secrets_manager" {
  source = "../../modules/secrets-manager"

  name_prefix = local.name_prefix
}

module "ssm" {
  source = "../../modules/ssm"

  name_prefix = local.name_prefix
}

module "elastic_ip" {
  source = "../../modules/elastic-ip"

  name_prefix = local.name_prefix
}

module "alb" {
  source = "../../modules/alb"

  name_prefix = local.name_prefix
}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name_prefix = local.name_prefix
}

module "ecs_service" {
  source = "../../modules/ecs-service"

  name_prefix = local.name_prefix
}

module "ec2" {
  source = "../../modules/ec2"

  name_prefix = local.name_prefix
}

module "rds" {
  source = "../../modules/rds"

  name_prefix = local.name_prefix
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name_prefix = local.name_prefix
}

module "eventbridge" {
  source = "../../modules/eventbridge"

  name_prefix = local.name_prefix
}
