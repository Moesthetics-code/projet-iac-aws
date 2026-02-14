# ═══════════════════════════════════════════════════════════════
# TERRAFORM EC2 - Instance avec Security Group
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
  region = var.aws_region
}

# ───────────────────────────────────────────────────────────────
# Data Sources - VPC par défaut
# ───────────────────────────────────────────────────────────────

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ───────────────────────────────────────────────────────────────
# Security Group
# ───────────────────────────────────────────────────────────────

resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.instance_name}-sg-"
  description = "Security group for ${var.instance_name}"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tout le trafic sortant
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.instance_name}-sg"
    Environment = var.instance_env
    ManagedBy   = "Terraform"
    Project     = "Sonatel-IAC"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ───────────────────────────────────────────────────────────────
# Instance EC2
# ───────────────────────────────────────────────────────────────

resource "aws_instance" "main" {
  ami           = var.instance_os
  instance_type = var.instance_size

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  # User data pour initialisation
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>SONATEL IAC - ${var.instance_name}</h1>" > /var/www/html/index.html
              EOF

  # Storage
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name        = "${var.instance_name}-root"
      Environment = var.instance_env
    }
  }

  tags = {
    Name        = var.instance_name
    Environment = var.instance_env
    ManagedBy   = "Terraform"
    Project     = "Sonatel-IAC"
  }

  lifecycle {
    create_before_destroy = true
  }
}
