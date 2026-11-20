output "topic_arn" {
  description = "ARN of the SNS topic (used as alarm action)"
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Full name of the SNS topic"
  value       = aws_sns_topic.this.name
}

output "subscription_count" {
  description = "Number of email subscriptions (each must confirm by email)"
  value       = length(aws_sns_topic_subscription.email)
}
