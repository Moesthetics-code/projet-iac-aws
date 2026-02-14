# ═══════════════════════════════════════════════════════════════
# RDS - main.tf
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

# Security Group pour RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.db_identifier}-sg-"
  description = "Security group for RDS ${var.db_identifier}"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Database access"
    from_port   = var.engine == "postgres" ? 5432 : var.engine == "mariadb" ? 3306 : 3306
    to_port     = var.engine == "postgres" ? 5432 : var.engine == "mariadb" ? 3306 : 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # À restreindre en production
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.db_identifier}-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name        = "${var.db_identifier}-subnet-group"
    Environment = var.environment
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = var.db_identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.allocated_storage * 2
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name != "" ? var.db_name : null
  username = var.username
  password = var.password

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.db_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = false

  enabled_cloudwatch_logs_exports = var.engine == "postgres" ? ["postgresql"] : ["error", "general", "slowquery"]

  performance_insights_enabled = var.environment == "prod"
  monitoring_interval          = var.environment == "prod" ? 60 : 0

  tags = {
    Name        = var.db_identifier
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Sonatel-IAC"
    Engine      = var.engine
  }

  lifecycle {
    ignore_changes = [password]
  }
}