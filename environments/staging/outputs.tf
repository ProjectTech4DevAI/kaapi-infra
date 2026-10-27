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

output "ecs_task_definitions" {
  description = "Per task definition: family, ARN, container names and the secret to fill in"
  value = {
    for name, td in module.ecs_task_definition : name => {
      family          = td.task_definition_family
      arn             = td.task_definition_arn
      container_names = td.container_names
      log_group       = td.log_group_name
    }
  }
}

output "ecs_services" {
  description = "ECS service name and task count limits per service"
  value = {
    for name, svc in module.ecs_service : name => {
      service_name = svc.service_name
      min_tasks    = svc.min_tasks
      max_tasks    = svc.max_tasks
    }
  }
}

output "monitoring" {
  description = "SNS alert topic, subscribed emails and CloudWatch alarm names"
  value = {
    topic_arn         = module.sns.topic_arn
    subscribed_emails = module.sns.subscribed_emails
    alarm_names       = module.cloudwatch.alarm_names
  }
}
