# ═══════════════════════════════════════════════════════════════════════════════
# AWS CodePipeline - Infrastructure Terraform
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

# ── S3 Bucket pour les artifacts ──────────────────────────────────────────
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "${var.pipeline_name}-artifacts-${random_string.suffix.result}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.pipeline_name}-artifacts"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "Sonatel-IAC"
    }
  )
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  rule {
    id     = "delete-old-artifacts"
    status = "Enabled"

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# ── IAM Role pour CodePipeline ────────────────────────────────────────────
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.pipeline_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.pipeline_name}-codepipeline-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.pipeline_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.pipeline_artifacts.arn,
          "${aws_s3_bucket.pipeline_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "lambda:ListFunctions",
          "lambda:UpdateFunctionCode",
          "lambda:GetFunctionConfiguration"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "ecs-tasks.amazonaws.com",
              "lambda.amazonaws.com"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.enable_notifications ? [aws_sns_topic.pipeline_notifications[0].arn] : []
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = var.source_provider == "GitHub" || var.source_provider == "GitHubEnterprise" || var.source_provider == "Bitbucket" ? var.github_connection_arn : "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── SNS Topic pour les notifications (optionnel) ──────────────────────────
resource "aws_sns_topic" "pipeline_notifications" {
  count = var.enable_notifications ? 1 : 0

  name = "${var.pipeline_name}-notifications"

  tags = merge(
    var.tags,
    {
      Name        = "${var.pipeline_name}-notifications"
      Environment = var.environment
    }
  )
}

resource "aws_sns_topic_policy" "pipeline_notifications" {
  count = var.enable_notifications ? 1 : 0

  arn = aws_sns_topic.pipeline_notifications[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codestar-notifications.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.pipeline_notifications[0].arn
      }
    ]
  })
}

# ── CodePipeline ───────────────────────────────────────────────────────────
resource "aws_codepipeline" "main" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  # STAGE 1: Source
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = local.source_provider_name
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = local.source_configuration
    }
  }

  # STAGE 2: Build (optionnel)
  dynamic "stage" {
    for_each = var.enable_build ? [1] : []

    content {
      name = "Build"

      action {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output"]
        version          = "1"

        configuration = {
          ProjectName = var.build_project_name
        }
      }
    }
  }

  # STAGE 3: Test (optionnel)
  dynamic "stage" {
    for_each = var.enable_test ? [1] : []

    content {
      name = "Test"

      action {
        name             = "Test"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = var.enable_build ? ["build_output"] : ["source_output"]
        output_artifacts = ["test_output"]
        version          = "1"

        configuration = {
          ProjectName = var.test_project_name
        }
      }
    }
  }

  # STAGE 4: Approval (optionnel)
  dynamic "stage" {
    for_each = var.manual_approval ? [1] : []

    content {
      name = "Approval"

      action {
        name     = "ManualApproval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"

        configuration = {
          NotificationArn = var.approval_sns_topic_arn != "" ? var.approval_sns_topic_arn : null
          CustomData      = "Approuver le déploiement en ${var.environment}"
        }
      }
    }
  }

  # STAGE 5: Deploy
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = local.deploy_provider_name
      input_artifacts = [local.deploy_input_artifact]
      version         = "1"

      configuration = local.deploy_configuration
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.pipeline_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "Sonatel-IAC"
    }
  )
}

# ── Locals pour configuration dynamique ───────────────────────────────────
locals {
  # Source provider mapping
  source_provider_name = (
    var.source_provider == "GitHub" || var.source_provider == "GitHubEnterprise" || var.source_provider == "Bitbucket" ? "CodeStarSourceConnection" :
    var.source_provider == "CodeCommit" ? "CodeCommit" :
    var.source_provider == "S3" ? "S3" :
    "CodeStarSourceConnection"
  )

  # Source configuration dynamique
  source_configuration = (
    var.source_provider == "GitHub" || var.source_provider == "GitHubEnterprise" || var.source_provider == "Bitbucket" ? {
      ConnectionArn    = var.github_connection_arn
      FullRepositoryId = var.repository
      BranchName       = var.branch
      OutputArtifactFormat = "CODE_ZIP"
    } :
    var.source_provider == "CodeCommit" ? {
      RepositoryName = var.codecommit_repository_name
      BranchName     = var.codecommit_branch
    } :
    var.source_provider == "S3" ? {
      S3Bucket    = var.s3_source_bucket
      S3ObjectKey = var.s3_source_object_key
    } :
    {}
  )

  # Deploy provider mapping
  deploy_provider_name = (
    var.deploy_provider == "ECS" || var.deploy_provider == "ECS-BlueGreen" ? "ECS" :
    var.deploy_provider == "CodeDeploy" ? "CodeDeploy" :
    var.deploy_provider == "Lambda" ? "Lambda" :
    var.deploy_provider == "S3" ? "S3" :
    var.deploy_provider == "CloudFormation" ? "CloudFormation" :
    var.deploy_provider == "EKS" ? "EKS" :
    "S3"
  )

  # Deploy input artifact
  deploy_input_artifact = (
    var.enable_test ? "test_output" :
    var.enable_build ? "build_output" :
    "source_output"
  )

  # Deploy configuration dynamique
  deploy_configuration = (
    var.deploy_provider == "ECS" || var.deploy_provider == "ECS-BlueGreen" ? {
      ClusterName = var.ecs_cluster_name
      ServiceName = var.ecs_service_name
      FileName    = var.ecs_image_definition_file
    } :
    var.deploy_provider == "CodeDeploy" ? {
      ApplicationName     = var.codedeploy_application_name
      DeploymentGroupName = var.codedeploy_deployment_group_name
    } :
    var.deploy_provider == "Lambda" ? {
      FunctionName = var.lambda_function_name
    } :
    var.deploy_provider == "S3" ? {
      BucketName = var.s3_deploy_bucket
      Extract    = var.s3_extract_archive ? "true" : "false"
    } :
    {}
  )
}

# ── CloudWatch Event Rule pour notifications (optionnel) ──────────────────
resource "aws_cloudwatch_event_rule" "pipeline_state_change" {
  count = var.enable_notifications ? 1 : 0

  name        = "${var.pipeline_name}-state-change"
  description = "Capture pipeline state changes"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      pipeline = [aws_codepipeline.main.name]
      state    = var.notification_events
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "sns" {
  count = var.enable_notifications ? 1 : 0

  rule      = aws_cloudwatch_event_rule.pipeline_state_change[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.pipeline_notifications[0].arn
}
