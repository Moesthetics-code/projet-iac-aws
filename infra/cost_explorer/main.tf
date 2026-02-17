# Cost Explorer - Note: Activation manuelle requise dans AWS Console
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
  region = "us-east-1"  # Cost Explorer is global
}

# IAM Policy pour Cost Explorer API
resource "aws_iam_policy" "cost_explorer" {
  name        = "cost-explorer-api-access"
  description = "Permissions pour Cost Explorer API"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetDimensionValues",
          "ce:GetTags"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# SNS Topic pour rapports (optionnel)
resource "aws_sns_topic" "cost_reports" {
  count = var.enable_reports ? 1 : 0
  name  = "cost-explorer-reports"
  tags  = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.enable_reports && var.report_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.cost_reports[0].arn
  protocol  = "email"
  endpoint  = var.report_email
}
