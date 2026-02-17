# AWS Systems Manager - Infrastructure Terraform
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

# SSM Parameters
resource "aws_ssm_parameter" "parameters" {
  for_each = { for p in var.parameters : p.name => p }

  name  = "${var.namespace}/${each.value.name}"
  type  = each.value.type
  value = each.value.value
  tier  = var.use_advanced_tier ? "Advanced" : "Standard"

  key_id = each.value.type == "SecureString" && var.kms_key_id != "" ? var.kms_key_id : null

  tags = merge(
    var.tags,
    {
      Name        = each.value.name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Namespace   = var.namespace
    }
  )
}

# IAM Role pour EC2 instances (Session Manager)
resource "aws_iam_role" "ssm_role" {
  count = var.enable_session_manager ? 1 : 0
  name  = "ssm-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  count      = var.enable_session_manager ? 1 : 0
  role       = aws_iam_role.ssm_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  count = var.enable_session_manager ? 1 : 0
  name  = "ssm-${var.environment}-profile"
  role  = aws_iam_role.ssm_role[0].name

  tags = var.tags
}

# CloudWatch Log Group pour Session Manager
resource "aws_cloudwatch_log_group" "session_logs" {
  count             = var.enable_session_manager && (var.session_logging == "cloudwatch" || var.session_logging == "both") ? 1 : 0
  name              = "/aws/ssm/sessions/${var.environment}"
  retention_in_days = 7

  tags = var.tags
}

# SSM Document pour Session Manager logging
resource "aws_ssm_document" "session_manager_prefs" {
  count           = var.enable_session_manager ? 1 : 0
  name            = "SSM-SessionManagerPreferences-${var.environment}"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Session Manager preferences for ${var.environment}"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName = var.session_logging == "s3" || var.session_logging == "both" ? var.s3_bucket_logs : ""
      cloudWatchLogGroupName = var.session_logging == "cloudwatch" || var.session_logging == "both" ? aws_cloudwatch_log_group.session_logs[0].name : ""
      cloudWatchEncryptionEnabled = var.session_logging == "cloudwatch" || var.session_logging == "both" ? true : false
    }
  })

  tags = var.tags
}
