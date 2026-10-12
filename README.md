# kaapi-infra

Terraform code for Kaapi's AWS infrastructure.

## Layout

```
kaapi-infra/
├── bootstrap/                  # One-time: S3 bucket for remote state
├── modules/                    # Reusable building blocks (no env-specific values)
│   ├── vpc/                    # VPC, subnets, IGW, NAT, routes, security groups
│   ├── ecs-cluster/            # ECS cluster
│   ├── ecs-service/            # Task definition + service
│   ├── alb/                    # Load balancer, listeners, target groups
│   ├── ec2/
│   ├── rds/
│   ├── elastic-ip/
│   ├── eventbridge/
│   ├── cloudwatch/
│   ├── iam/
│   ├── ecr/
│   ├── secrets-manager/
│   ├── kms/
│   └── ssm/
├── environments/               # One folder per environment = one isolated state
│   ├── staging/
│   │   ├── backend.tf          # state key: staging/terraform.tfstate
│   │   ├── providers.tf
│   │   ├── versions.tf
│   │   ├── locals.tf           # name prefix + common tags
│   │   ├── variables.tf
│   │   ├── main.tf             # calls modules/*
│   │   ├── outputs.tf
│   │   └── terraform.tfvars    # all staging-specific values
│   └── prod/                   # same files, prod values
└── Makefile
```

- **modules/** contain the logic and never hold environment values.
- **environments/<env>/** contain only wiring and values. Each one has its own state file, so changing staging can never touch prod.

## First-time setup

```bash
cd bootstrap
terraform init
terraform apply      # creates the kaapi-terraform-<environment>-state bucket
```

## Day-to-day

```bash
make init     ENV=staging
make plan     ENV=staging
make apply    ENV=staging
```

Replace `staging` with `prod` for production.

## Adding a new environment (e.g. `dev`)

1. `cp -r environments/staging environments/dev`
2. In `environments/dev/backend.tf`, change `key` to `dev/terraform.tfstate`.
3. In `environments/dev/terraform.tfvars`, set `environment = "dev"` and a non-overlapping `vpc_cidr`.
4. `make init ENV=dev && make plan ENV=dev`

## Secrets

Never commit secret values. Keep them in `*.secret.tfvars` (gitignored) or in Secrets Manager directly.
