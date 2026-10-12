# kaapi-infra

Infrastructure as Code for Kaapi, written in Terraform. This repo is the single source of truth for everything Kaapi runs on AWS: networking (VPC, subnets, Elastic IPs), compute (ECS services behind an ALB, and EC2 instances), the RDS database, container images (ECR), configuration and secrets (SSM Parameter Store, Secrets Manager, KMS), scheduling (EventBridge), monitoring (CloudWatch) and access control (IAM).

Each environment (`staging`, `prod`, and any added later) is built from the same shared modules but has its own values, its own AWS profile and account guard, and its own remote state in S3. A change applied to one environment can never affect another.

> Make infra changes here and apply them with Terraform. Do not edit these resources by hand in the AWS console: Terraform will undo or conflict with manual changes on the next apply.
