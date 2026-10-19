# ecs-task-definition

ECS task definition (one or more containers) plus its CloudWatch log group and IAM execution/task roles. Secrets are referenced from the secrets-manager module, not created here. Does not run anything; the ecs-service module does that.

| File           | Purpose                         |
|----------------|---------------------------------|
| main.tf        | Resources                       |
| variables.tf   | Inputs                          |
| outputs.tf     | Values exposed to other modules |
| versions.tf    | Terraform / provider constraints |
