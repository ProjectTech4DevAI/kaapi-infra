# Outputs of the staging environment.

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URLs, by short name"
  value       = module.ecr.repository_urls
}
