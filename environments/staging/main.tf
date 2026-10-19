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

  name_prefix          = local.name_prefix
  repositories         = var.ecr_repositories
  image_tag_mutability = var.ecr_image_tag_mutability
  max_image_count      = var.ecr_max_image_count
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

  name_prefix        = local.name_prefix
  container_insights = var.ecs_container_insights
}

module "ecs_task_definition" {
  source   = "../../modules/ecs-task-definition"
  for_each = var.ecs_task_definitions

  name_prefix           = local.name_prefix
  name                  = each.key
  launch_type           = var.ecs_launch_type
  cpu_architecture      = each.value.cpu_architecture
  cpu                   = each.value.cpu
  memory                = each.value.memory
  image_repository_urls = module.ecr.repository_urls
  image_tag             = each.value.image_tag
  containers            = each.value.containers
  environment           = each.value.environment

  secrets            = each.value.secrets
  log_retention_days = var.ecs_log_retention_days
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
