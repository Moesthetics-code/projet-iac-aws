# ═══════════════════════════════════════════════════════════════
# CLOUDWATCH - main.tf
# ═══════════════════════════════════════════════════════════════

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
  region = "eu-west-3"
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "main" {
  alarm_name          = var.alarm_name
  alarm_description   = var.alarm_description
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  tags = {
    Name      = var.alarm_name
    ManagedBy = "Terraform"
  }
}

# Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/cloudwatch/${var.alarm_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.alarm_name}-logs"
  }
}
