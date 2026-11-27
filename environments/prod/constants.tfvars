project     = "kaapi"
environment = "production"

# ECS
ecs_container_insights = "enabled" # enabled | enhanced | disabled (enabled/enhanced add CloudWatch cost)

# ECR
ecr_repositories         = ["backend"] # becomes kaapi-production-backend
ecr_image_tag_mutability = "MUTABLE"   # MUTABLE | IMMUTABLE
ecr_max_image_count      = 10

ecs_launch_type        = "FARGATE"
ecs_log_retention_days = 14

ecs_task_definitions = {
  "backend-celery" = {
    cpu              = 2048
    memory           = 6144
    cpu_architecture = "X86_64"

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
      ENVIRONMENT                        = "production"
      MEMORY_THRESHOLD_PERCENT           = "REPLACE_ME"
      OTEL_ENABLED                       = "true"
      PROJECT_NAME                       = "Kaapi"
      RESOURCE_CHECK_INTERVAL            = "REPLACE_ME"
      RESOURCE_MONITORING_ENABLED        = "REPLACE_ME"
      STACK_NAME                         = "REPLACE_ME"
    }

    secrets = {
      db = [
        "POSTGRES_DB",
        "POSTGRES_PORT",
        "POSTGRES_SERVER",
        "POSTGRES_USER",
        "POSTGRES_PASSWORD",
      ]
      rabbitmq = [
        "RABBITMQ_HOST",
        "RABBITMQ_PORT",
        "RABBITMQ_USER",
        "RABBITMQ_VHOST",
        "RABBITMQ_PASSWORD",
      ]
      redis = [
        "REDIS_DB",
        "REDIS_HOST",
        "REDIS_PORT",
        "REDIS_PASSWORD",
      ]
      config = [
        "AWS_KMS_KEY_ID",
        "AWS_S3_BUCKET_PREFIX",
        "BACKEND_CORS_ORIGINS",
        "EMAILS_FROM_NAME",
        "FIRST_SUPERUSER_PASSWORD",
        "FRONTEND_HOST",
        "GCP_PROJECT_ID",
        "GCP_SA_KEY",
        "GCP_VERTEX_API_KEY",
        "GCP_VERTEX_LOCATION",
        "GCS_AUDIO_BUCKET",
        "GOOGLE_CLIENT_ID",
        "KAAPI_GUARDRAILS_AUTH",
        "KAAPI_GUARDRAILS_URL",
        "LANGFUSE_HOST",
        "LANGFUSE_PUBLIC_KEY",
        "LANGFUSE_SECRET_KEY",
        "OPENAI_API_KEY",
        "OTEL_SERVICE_NAME",
        "SECRET_KEY",
        "SENTRY_DSN",
        "SMTP_HOST",
        "SMTP_PASSWORD",
        "SMTP_PORT",
        "SMTP_SSL",
        "SMTP_TLS",
      ]
    }
  }
}

vpc_cidr = "REPLACE_ME"

ecs_assign_public_ip = false

ecs_services = {
  "backend-celery" = {
    task_definition    = "backend-celery"
    min_tasks          = 0
    max_tasks          = 0
    cpu_target_percent = 70

    # Send ALB traffic to the web container. Remove this block if there is no ALB.
    # load_balancer = {
    #   target_group_arn = "REPLACE_ME"
    #   container        = "backend"
    # }
  }
}

# Monitoring
monitoring_alert_topic_name             = "monitoring-alerts" # becomes kaapi-staging-monitoring-alerts
monitoring_ecs_cpu_threshold_percent    = 80
monitoring_ecs_memory_threshold_percent = 80

monitoring_ec2_cpu_threshold_percent    = 80
monitoring_ec2_memory_threshold_percent = 80
monitoring_ec2_disk_threshold_percent   = 80
