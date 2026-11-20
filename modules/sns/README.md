# sns

SNS topic for monitoring alerts with email subscriptions. Every address must click the confirmation link AWS sends before it receives alerts.

Addresses are treated as sensitive: subscriptions are keyed by a SHA-256 hash of each address and the module only outputs `subscription_count`, so emails never appear in plan output, CI summaries or resource addresses.
