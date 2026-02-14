# ═══════════════════════════════════════════════════════════════
# ROUTE 53 - main.tf
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

# Zone DNS
resource "aws_route53_zone" "main" {
  name = var.zone_name

  dynamic "vpc" {
    for_each = var.zone_type == "private" ? [1] : []
    content {
      vpc_id = var.vpc_id
    }
  }

  tags = {
    Name      = var.zone_name
    ManagedBy = "Terraform"
  }
}

# Enregistrement DNS
resource "aws_route53_record" "main" {
  count   = var.record_name != "" ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = var.record_name != "" ? "${var.record_name}.${var.zone_name}" : var.zone_name
  type    = var.record_type
  ttl     = var.ttl
  records = [var.record_value]
}

# Health Check (optionnel)
resource "aws_route53_health_check" "main" {
  count             = var.enable_health_check ? 1 : 0
  fqdn              = var.record_name != "" ? "${var.record_name}.${var.zone_name}" : var.zone_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.zone_name}-health-check"
  }
}
