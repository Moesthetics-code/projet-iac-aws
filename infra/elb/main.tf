# ═══════════════════════════════════════════════════════════════
# ELB - main.tf
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Load Balancer
resource "aws_lb" "main" {
  name               = var.lb_name
  internal           = var.scheme == "internal"
  load_balancer_type = var.lb_type
  subnets            = var.subnet_ids != [] ? var.subnet_ids : data.aws_subnets.default.ids

  enable_deletion_protection = false
  enable_http2              = true

  tags = {
    Name      = var.lb_name
    ManagedBy = "Terraform"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.lb_name}-tg"
  port     = var.target_group_port
  protocol = var.lb_type == "application" ? "HTTP" : "TCP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.lb_type == "application" ? var.health_check_path : null
    protocol            = var.lb_type == "application" ? "HTTP" : "TCP"
  }

  tags = {
    Name = "${var.lb_name}-tg"
  }
}

# Listener HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = var.lb_type == "application" ? "HTTP" : "TCP"

  default_action {
    type = var.http_action == "redirect" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.http_action == "redirect" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.http_action == "forward" ? aws_lb_target_group.main.arn : null
  }
}

# Listener HTTPS (optionnel)
resource "aws_lb_listener" "https" {
  count             = var.ssl_certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = var.lb_type == "application" ? "HTTPS" : "TLS"
  ssl_policy        = var.lb_type == "application" ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
