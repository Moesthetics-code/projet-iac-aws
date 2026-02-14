# ═══════════════════════════════════════════════════════════════
# CLOUDFRONT - main.tf
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
  region = "us-east-1"  # CloudFront nécessite us-east-1
}

# Origin Access Identity (pour S3)
resource "aws_cloudfront_origin_access_identity" "main" {
  count   = var.origin_type == "s3" ? 1 : 0
  comment = "OAI for ${var.origin_domain}"
}

# Distribution CloudFront
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = var.ipv6
  comment             = var.distribution_comment
  default_root_object = var.origin_type == "s3" ? "index.html" : null
  price_class         = var.price_class
  aliases             = var.aliases != "" ? split(",", replace(var.aliases, " ", "")) : []

  # Origin
  origin {
    domain_name = var.origin_domain
    origin_id   = "primary"

    dynamic "s3_origin_config" {
      for_each = var.origin_type == "s3" ? [1] : []
      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.main[0].cloudfront_access_identity_path
      }
    }

    dynamic "custom_origin_config" {
      for_each = var.origin_type == "custom" ? [1] : []
      content {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "primary"
    viewer_protocol_policy = var.viewer_protocol_policy
    compress               = var.compress

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = var.default_ttl
    max_ttl     = 31536000
  }

  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL Certificate
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == ""
    acm_certificate_arn            = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    ssl_support_method             = var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  # Logging
  dynamic "logging_config" {
    for_each = var.logging ? [1] : []
    content {
      include_cookies = false
      bucket          = "${var.origin_domain}.s3.amazonaws.com"
      prefix          = "cloudfront-logs/"
    }
  }

  tags = {
    Name      = var.distribution_comment
    ManagedBy = "Terraform"
  }
}
