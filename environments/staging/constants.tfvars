project     = "kaapi"
environment = "staging"

# ECS
ecs_container_insights = "disabled" # enabled | enhanced | disabled (enabled/enhanced add CloudWatch cost)

# ECR
ecr_repositories         = ["backend"] # becomes kaapi-staging-backend
ecr_image_tag_mutability = "MUTABLE"   # MUTABLE | IMMUTABLE
ecr_max_image_count      = 10

ecs_launch_type        = "FARGATE"
ecs_log_retention_days = 14

ecs_task_definitions = {
  "backend-celery" = {
    cpu              = 2048
    memory           = 6144
    cpu_architecture = "X86_64"

    execution_role_name = "REPLACE_ME"
    task_role_name      = "REPLACE_ME"

    containers = {
      backend = {
        image_repository = "backend"
        container_port   = 80
      }

      "backend-celery" = {
        image_repository = "backend"
        command          = ["uv", "run", "celery", "-A", "app.celery.celery_app", "worker", "--queues=default", "--concurrency=4", "--loglevel=info"]
      }
    }

    environment = {
      API_VERSION                        = "REPLACE_ME"
      CALLBACK_CONNECT_TIMEOUT           = "REPLACE_ME"
      CALLBACK_READ_TIMEOUT              = "REPLACE_ME"
      CELERY_TASK_SOFT_TIME_LIMIT        = "REPLACE_ME"
      CELERY_TASK_TIME_LIMIT             = "REPLACE_ME"
      CELERY_WORKER_MAX_MEMORY_PER_CHILD = "REPLACE_ME"
      CELERY_WORKER_MAX_TASKS_PER_CHILD  = "90"
      CPU_THRESHOLD_PERCENT              = "REPLACE_ME"
      DOCKER_IMAGE_BACKEND               = "backend"
      DOCKER_IMAGE_FRONTEND              = "frontend"
      ENVIRONMENT                        = "staging"
      MEMORY_THRESHOLD_PERCENT           = "REPLACE_ME"
      OTEL_ENABLED                       = "true"
      PROJECT_NAME                       = "Kaapi Staging"
      RESOURCE_CHECK_INTERVAL            = "REPLACE_ME"
      RESOURCE_MONITORING_ENABLED        = "REPLACE_ME"
      STACK_NAME                         = "REPLACE_ME"
    }

    secrets = {
      POSTGRES_DB              = { secret = "REPLACE_ME", key = "POSTGRES_DB" }
      POSTGRES_PORT            = { secret = "REPLACE_ME", key = "POSTGRES_PORT" }
      POSTGRES_SERVER          = { secret = "REPLACE_ME", key = "POSTGRES_SERVER" }
      POSTGRES_USER            = { secret = "REPLACE_ME", key = "POSTGRES_USER" }
      POSTGRES_PASSWORD        = { secret = "REPLACE_ME", key = "POSTGRES_PASSWORD" }
      RABBITMQ_HOST            = { secret = "REPLACE_ME", key = "RABBITMQ_HOST" }
      RABBITMQ_PORT            = { secret = "REPLACE_ME", key = "RABBITMQ_PORT" }
      RABBITMQ_USER            = { secret = "REPLACE_ME", key = "RABBITMQ_USER" }
      RABBITMQ_VHOST           = { secret = "REPLACE_ME", key = "RABBITMQ_VHOST" }
      RABBITMQ_PASSWORD        = { secret = "REPLACE_ME", key = "RABBITMQ_PASSWORD" }
      REDIS_DB                 = { secret = "REPLACE_ME", key = "REDIS_DB" }
      REDIS_HOST               = { secret = "REPLACE_ME", key = "REDIS_HOST" }
      REDIS_PORT               = { secret = "REPLACE_ME", key = "REDIS_PORT" }
      REDIS_PASSWORD           = { secret = "REPLACE_ME", key = "REDIS_PASSWORD" }
      FIRST_SUPERUSER_PASSWORD = { secret = "REPLACE_ME", key = "FIRST_SUPERUSER_PASSWORD" }
      GCP_SA_KEY               = { secret = "REPLACE_ME", key = "GCP_SA_KEY" }
      GCP_VERTEX_API_KEY       = { secret = "REPLACE_ME", key = "GCP_VERTEX_API_KEY" }
      KAAPI_GUARDRAILS_AUTH    = { secret = "REPLACE_ME", key = "KAAPI_GUARDRAILS_AUTH" }
      LANGFUSE_SECRET_KEY      = { secret = "REPLACE_ME", key = "LANGFUSE_SECRET_KEY" }
      OPENAI_API_KEY           = { secret = "REPLACE_ME", key = "OPENAI_API_KEY" }
      SECRET_KEY               = { secret = "REPLACE_ME", key = "SECRET_KEY" }
      SENTRY_DSN               = { secret = "REPLACE_ME", key = "SENTRY_DSN" }
      SMTP_PASSWORD            = { secret = "REPLACE_ME", key = "SMTP_PASSWORD" }
      GCP_PROJECT_ID           = { secret = "REPLACE_ME", key = "GCP_PROJECT_ID" }
      GCP_VERTEX_LOCATION      = { secret = "REPLACE_ME", key = "GCP_VERTEX_LOCATION" }
      GCS_AUDIO_BUCKET         = { secret = "REPLACE_ME", key = "GCS_AUDIO_BUCKET" }
      GOOGLE_CLIENT_ID         = { secret = "REPLACE_ME", key = "GOOGLE_CLIENT_ID" }
      KAAPI_GUARDRAILS_URL     = { secret = "REPLACE_ME", key = "KAAPI_GUARDRAILS_URL" }
      LANGFUSE_HOST            = { secret = "REPLACE_ME", key = "LANGFUSE_HOST" }
      LANGFUSE_PUBLIC_KEY      = { secret = "REPLACE_ME", key = "LANGFUSE_PUBLIC_KEY" }
      OTEL_SERVICE_NAME        = { secret = "REPLACE_ME", key = "OTEL_SERVICE_NAME" }
      SMTP_HOST                = { secret = "REPLACE_ME", key = "SMTP_HOST" }
      SMTP_PORT                = { secret = "REPLACE_ME", key = "SMTP_PORT" }
      SMTP_SSL                 = { secret = "REPLACE_ME", key = "SMTP_SSL" }
      SMTP_TLS                 = { secret = "REPLACE_ME", key = "SMTP_TLS" }
      AWS_KMS_KEY_ID           = { secret = "REPLACE_ME", key = "AWS_KMS_KEY_ID" }
      AWS_S3_BUCKET_PREFIX     = { secret = "REPLACE_ME", key = "AWS_S3_BUCKET_PREFIX" }
      BACKEND_CORS_ORIGINS     = { secret = "REPLACE_ME", key = "BACKEND_CORS_ORIGINS" }
      EMAILS_FROM_NAME         = { secret = "REPLACE_ME", key = "EMAILS_FROM_NAME" }
      FRONTEND_HOST            = { secret = "REPLACE_ME", key = "FRONTEND_HOST" }
    }
  }
}

ecs_assign_public_ip = false

ecs_services = {
  "backend-celery" = {
    task_definition    = "backend-celery"
    min_tasks          = 1
    max_tasks          = 2
    cpu_target_percent = 70

    # Send ALB traffic to the web container. Remove this block if there is no ALB.
    load_balancer = {
      target_group_arn = "REPLACE_ME"
      container        = "backend"
    }
  }
}

# Monitoring (alert emails and EC2 instances come from GitHub secrets)
monitoring_alert_topic_name             = "monitoring-alerts" # becomes kaapi-staging-monitoring-alerts
monitoring_ecs_cpu_threshold_percent    = 80
monitoring_ecs_memory_threshold_percent = 80

monitoring_ec2_cpu_threshold_percent    = 80
monitoring_ec2_memory_threshold_percent = 80
monitoring_ec2_disk_threshold_percent   = 80
