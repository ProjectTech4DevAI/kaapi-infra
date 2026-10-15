output "repository_urls" {
  description = "Map of short name => repository URL (used for docker push and task definitions)"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "repository_arns" {
  description = "Map of short name => repository ARN (used in IAM policies)"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}
