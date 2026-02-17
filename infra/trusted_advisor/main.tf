# Trusted Advisor - Notifications
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
  region = "us-east-1"  # Trusted Advisor est global
}

# SNS Topic pour notifications
resource "aws_sns_topic" "trusted_advisor" {
  name = "trusted-advisor-notifications"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.trusted_advisor.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# EventBridge Rule pour Trusted Advisor Check
resource "aws_cloudwatch_event_rule" "ta_check" {
  name        = "trusted-advisor-check-refresh"
  description = "Capture Trusted Advisor check status changes"

  event_pattern = jsonencode({
    source      = ["aws.trustedadvisor"]
    detail-type = ["Trusted Advisor Check Item Refresh Notification"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "ta_sns" {
  rule      = aws_cloudwatch_event_rule.ta_check.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.trusted_advisor.arn
}

# Permission pour EventBridge
resource "aws_sns_topic_policy" "ta_policy" {
  arn = aws_sns_topic.trusted_advisor.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.trusted_advisor.arn
      }
    ]
  })
}

# IAM Policy pour accès API Trusted Advisor
resource "aws_iam_policy" "ta_access" {
  name        = "trusted-advisor-api-access"
  description = "Permissions pour Trusted Advisor API"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "support:DescribeTrustedAdvisorChecks",
          "support:DescribeTrustedAdvisorCheckResult",
          "support:RefreshTrustedAdvisorCheck"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}
