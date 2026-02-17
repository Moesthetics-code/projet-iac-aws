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
  region = "us-east-1"  # Budgets is global but requires us-east-1
}

resource "aws_budgets_budget" "main" {
  name              = var.budget_name
  budget_type       = "COST"
  limit_amount      = var.budget_amount
  limit_unit        = "USD"
  time_unit         = var.time_unit
  time_period_start = formatdate("YYYY-MM-01_00:00", timestamp())

  dynamic "notification" {
    for_each = var.alert_thresholds
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value.threshold
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = notification.value.emails
    }
  }

  cost_types {
    include_credit             = false
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = false
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_blended                = false
  }

  tags = merge(
    var.tags,
    {
      Name      = var.budget_name
      ManagedBy = "Terraform"
      Project   = "Sonatel-IAC"
    }
  )
}
