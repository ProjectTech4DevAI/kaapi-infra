project     = "kaapi"
environment = "staging"

# ECS
ecs_container_insights = "disabled" # enabled | enhanced | disabled (enabled/enhanced add CloudWatch cost)

# ECR
ecr_repositories         = ["backend-repo"] # becomes kaapi-staging-backend
ecr_image_tag_mutability = "MUTABLE"        # MUTABLE | IMMUTABLE
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
        image_repository = "backend-repo"
        container_port   = 80
      }

      "backend-celery" = {
        image_repository = "backend-repo"
        command          = ["uv", "run", "celery", "-A", "app.celery.celery_app", "worker", "--queues=default", "--concurrency=4", "--loglevel=info"]
      }

      "evaluations-celery" : {
        image_repository = "backend-repo"
        command          = ["uv", "run", "celery", "-A", "app.celery.celery_app", "worker", "--queues=evaluations", "--concurrency=2", "--loglevel=info"]
      }
    }

    environment = {
      API_VERSION                        = "0.5.0"
      CALLBACK_CONNECT_TIMEOUT           = "3"
      CALLBACK_READ_TIMEOUT              = "10"
      CELERY_TASK_SOFT_TIME_LIMIT        = "1200"
      CELERY_TASK_TIME_LIMIT             = "1500"
      CELERY_WORKER_MAX_MEMORY_PER_CHILD = "300000"
      CELERY_WORKER_MAX_TASKS_PER_CHILD  = "90"
      CPU_THRESHOLD_PERCENT              = "75.0"
      DOCKER_IMAGE_BACKEND               = "backend"
      DOCKER_IMAGE_FRONTEND              = "frontend"
      ENVIRONMENT                        = "staging"
      MEMORY_THRESHOLD_PERCENT           = "75.0"
      OTEL_ENABLED                       = "true"
      PROJECT_NAME                       = "Kaapi"
      RESOURCE_CHECK_INTERVAL            = "5"
      RESOURCE_MONITORING_ENABLED        = "True"
      STACK_NAME                         = "kaapi-staging"
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
        "EMAIL_TEST_USER",
        "EMAILS_FROM_EMAIL",
        "EMAILS_FROM_NAME",
        "FIRST_SUPERUSER",
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
        "SMTP_USER",
      ]
    }
  }
}

vpc_cidr = "10.0.0.0/16"

ecs_assign_public_ip = true

ecs_services = {
  "backend-celery-service" = {
    task_definition    = "backend-celery"
    min_tasks          = 0
    max_tasks          = 0
    cpu_target_percent = 70
  }
}

# Monitoring (alert emails and EC2 instances come from GitHub secrets)
monitoring_alert_topic_name             = "monitoring-alerts" # becomes kaapi-staging-monitoring-alerts
monitoring_ecs_cpu_threshold_percent    = 80
monitoring_ecs_memory_threshold_percent = 80

monitoring_ec2_cpu_threshold_percent    = 80
monitoring_ec2_memory_threshold_percent = 80
monitoring_ec2_disk_threshold_percent   = 80

ec2_instances = {
  "frontend-ui-guardrails" = {
    name                 = "ui-guardrails" # Name tag kaapi-staging-ui-guardrails
    instance_type        = "t3.large"
    iam_instance_profile = "app-kaapi-staging-ssm-role"
  }

  "backend" = {
    name                 = "backend" # Name tag kaapi-staging-backend
    instance_type        = "t3.medium"
    iam_instance_profile = "app-backend-ec2-instance-role"
    tags = {
      Environment = "Staging"
      Product     = "Kaapi"
    }
  }

  "ssm-bastion" = {
    name                 = "ssm-bastion" # Name tag kaapi-staging-ssm-bastion
    instance_type        = "t3a.nano"
    iam_instance_profile = "app-kaapi-staging-ssm-role"
  }

  "rabbitmq-redis" = {
    name          = "rabbitmq-redis" # Name tag kaapi-staging-rabbitmq-redis
    instance_type = "t3.small"       # no IAM instance profile attached
    tags = {
      Product = "Kaapi"
    }
  }
}

# Instances to alarm on (CPU + status check; memory + disk need the CloudWatch agent)
monitoring_ec2_instances = {
  "frontend-ui-guardrails" = {}
  "backend"                = {}
}
