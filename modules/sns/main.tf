resource "aws_sns_topic" "this" {
  name = "${var.name_prefix}-${var.topic_name}"
}

locals {
  emails_by_hash = { for e in var.email_addresses : sha256(lower(trimspace(e))) => e }
}

resource "aws_sns_topic_subscription" "email" {
  for_each = nonsensitive(toset(keys(local.emails_by_hash)))

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = local.emails_by_hash[each.key]
}
