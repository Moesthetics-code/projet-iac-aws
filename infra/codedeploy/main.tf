# AWS CodeDeploy - Infrastructure Terraform
# Projet IAC SONATEL

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

# IAM Role pour CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.application_name}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.application_name}-codedeploy-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = var.compute_platform == "Lambda" ? "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda" : var.compute_platform == "ECS" ? "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS" : "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# CodeDeploy Application
resource "aws_codedeploy_app" "main" {
  name             = var.application_name
  compute_platform = var.compute_platform

  tags = merge(
    var.tags,
    {
      Name        = var.application_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "Sonatel-IAC"
    }
  )
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = var.deployment_config_name

  dynamic "ec2_tag_set" {
    for_each = var.compute_platform == "Server" && length(var.ec2_tag_filters) > 0 ? [1] : []
    content {
      dynamic "ec2_tag_filter" {
        for_each = var.ec2_tag_filters
        content {
          key   = ec2_tag_filter.value.key
          type  = ec2_tag_filter.value.type
          value = ec2_tag_filter.value.value
        }
      }
    }
  }

  dynamic "auto_scaling_groups" {
    for_each = var.compute_platform == "Server" && length(var.autoscaling_groups) > 0 ? [1] : []
    content {
      for_each = var.autoscaling_groups
    }
  }

  dynamic "ecs_service" {
    for_each = var.compute_platform == "ECS" ? [1] : []
    content {
      cluster_name = var.ecs_cluster_name
      service_name = var.ecs_service_name
    }
  }

  dynamic "load_balancer_info" {
    for_each = var.use_load_balancer ? [1] : []
    content {
      dynamic "target_group_info" {
        for_each = var.load_balancer_type == "target_group" ? [1] : []
        content {
          name = var.target_group_name
        }
      }

      dynamic "elb_info" {
        for_each = var.load_balancer_type == "classic" ? [1] : []
        content {
          name = var.classic_lb_name
        }
      }
    }
  }

  dynamic "blue_green_deployment_config" {
    for_each = var.compute_platform == "Server" && var.blue_green_enabled ? [1] : []
    content {
      terminate_blue_instances_on_deployment_success {
        action                           = var.terminate_blue_instances
        termination_wait_time_in_minutes = var.blue_green_timeout
      }

      deployment_ready_option {
        action_on_timeout = "CONTINUE_DEPLOYMENT"
      }

      green_fleet_provisioning_option {
        action = var.green_fleet_option
      }
    }
  }

  auto_rollback_configuration {
    enabled = var.auto_rollback_enabled
    events  = var.auto_rollback_events
  }

  dynamic "alarm_configuration" {
    for_each = var.rollback_on_alarm && length(var.cloudwatch_alarms) > 0 ? [1] : []
    content {
      alarms  = var.cloudwatch_alarms
      enabled = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.deployment_group_name
      Environment = var.environment
    }
  )
}

# SNS Topic pour notifications (optionnel)
resource "aws_sns_topic" "deployment_notifications" {
  count = var.enable_notifications ? 1 : 0

  name = "${var.application_name}-deployment-notifications"

  tags = var.tags
}
