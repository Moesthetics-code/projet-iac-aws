# ═══════════════════════════════════════════════════════════════════════════════
# AWS CodeBuild - Infrastructure Terraform
# Projet IAC SONATEL
# ═══════════════════════════════════════════════════════════════════════════════

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ── IAM Role pour CodeBuild ────────────────────────────────────────────────
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-codebuild-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.region}:*:log-group:/aws/codebuild/${var.project_name}",
          "arn:aws:logs:${var.region}:*:log-group:/aws/codebuild/${var.project_name}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = concat(
          var.artifacts_type == "S3" && var.artifacts_bucket != "" ? [
            "arn:aws:s3:::${var.artifacts_bucket}",
            "arn:aws:s3:::${var.artifacts_bucket}/*"
          ] : [],
          var.enable_cache && var.cache_bucket != "" ? [
            "arn:aws:s3:::${var.cache_bucket}",
            "arn:aws:s3:::${var.cache_bucket}/*"
          ] : [],
          var.s3_logs_enabled && var.s3_logs_bucket != "" ? [
            "arn:aws:s3:::${var.s3_logs_bucket}",
            "arn:aws:s3:::${var.s3_logs_bucket}/*"
          ] : []
        )
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GitPull"
        ]
        Resource = var.source_type == "CODECOMMIT" && var.source_location != "" ? [
          var.source_location
        ] : ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── CloudWatch Log Group ───────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "codebuild_logs" {
  count = var.cloudwatch_logs_enabled ? 1 : 0

  name              = "/aws/codebuild/${var.project_name}"
  retention_in_days = var.logs_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-logs"
      Environment = var.environment
    }
  )
}

# ── CodeBuild Project ──────────────────────────────────────────────────────
resource "aws_codebuild_project" "main" {
  name          = var.project_name
  description   = var.description
  build_timeout = var.timeout_minutes
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type      = var.artifacts_type
    location  = var.artifacts_type == "S3" ? var.artifacts_bucket : null
    path      = var.artifacts_type == "S3" ? var.artifacts_path : null
    packaging = var.artifacts_type == "S3" ? var.artifacts_packaging : null
  }

  dynamic "cache" {
    for_each = var.enable_cache ? [1] : []
    content {
      type     = "S3"
      location = "${var.cache_bucket}/${var.project_name}"
      modes    = ["LOCAL_CUSTOM_CACHE"]
    }
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image == "CUSTOM" ? var.custom_image : var.image
    type                        = var.environment_type
    image_pull_credentials_type = var.image == "CUSTOM" ? "SERVICE_ROLE" : "CODEBUILD"
    privileged_mode             = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = lookup(environment_variable.value, "type", "PLAINTEXT")
      }
    }
  }

  logs_config {
    dynamic "cloudwatch_logs" {
      for_each = var.cloudwatch_logs_enabled ? [1] : []
      content {
        status     = "ENABLED"
        group_name = aws_cloudwatch_log_group.codebuild_logs[0].name
      }
    }

    dynamic "s3_logs" {
      for_each = var.s3_logs_enabled ? [1] : []
      content {
        status   = "ENABLED"
        location = "${var.s3_logs_bucket}/${var.project_name}"
      }
    }
  }

  source {
    type            = var.source_type
    location        = var.source_type != "NO_SOURCE" && var.source_type != "CODEPIPELINE" ? var.source_location : null
    buildspec       = var.buildspec_type == "inline" ? var.buildspec : null
    git_clone_depth = var.source_type == "GITHUB" || var.source_type == "GITHUB_ENTERPRISE" || var.source_type == "BITBUCKET" ? var.git_clone_depth : null

    dynamic "git_submodules_config" {
      for_each = var.fetch_git_submodules && (var.source_type == "GITHUB" || var.source_type == "GITHUB_ENTERPRISE" || var.source_type == "BITBUCKET" || var.source_type == "CODECOMMIT") ? [1] : []
      content {
        fetch_submodules = true
      }
    }
  }

  dynamic "secondary_sources" {
    for_each = var.secondary_sources
    content {
      type              = secondary_sources.value.type
      location          = secondary_sources.value.location
      source_identifier = secondary_sources.value.identifier
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "Sonatel-IAC"
    }
  )
}

# ── CloudWatch Event Rule pour notifications (optionnel) ──────────────────
resource "aws_cloudwatch_event_rule" "build_state_change" {
  count = var.enable_notifications ? 1 : 0

  name        = "${var.project_name}-build-state-change"
  description = "Capture CodeBuild state changes"

  event_pattern = jsonencode({
    source      = ["aws.codebuild"]
    detail-type = ["CodeBuild Build State Change"]
    detail = {
      project-name = [aws_codebuild_project.main.name]
      build-status = ["IN_PROGRESS", "SUCCEEDED", "FAILED", "STOPPED"]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "sns" {
  count = var.enable_notifications ? 1 : 0

  rule      = aws_cloudwatch_event_rule.build_state_change[0].name
  target_id = "SendToSNS"
  arn       = var.notification_sns_topic_arn
}

# ── SNS Topic Subscription (optionnel) ────────────────────────────────────
resource "aws_sns_topic_subscription" "notification_email" {
  count = var.enable_notifications && length(var.notification_emails) > 0 ? length(var.notification_emails) : 0

  topic_arn = var.notification_sns_topic_arn
  protocol  = "email"
  endpoint  = var.notification_emails[count.index]
}

# ── Webhook pour GitHub (optionnel) ────────────────────────────────────────
resource "aws_codebuild_webhook" "github" {
  count = var.enable_github_webhook && (var.source_type == "GITHUB" || var.source_type == "GITHUB_ENTERPRISE") ? 1 : 0

  project_name = aws_codebuild_project.main.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH, PULL_REQUEST_CREATED, PULL_REQUEST_UPDATED"
    }

    filter {
      type    = "HEAD_REF"
      pattern = var.webhook_branch_filter
    }
  }
}
