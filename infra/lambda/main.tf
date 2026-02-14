# ═══════════════════════════════════════════════════════════════
# TERRAFORM LAMBDA - main.tf
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

# ───────────────────────────────────────────────────────────────
# IAM Role pour Lambda
# ───────────────────────────────────────────────────────────────

resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.function_name}-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Attachement de la politique d'exécution basique
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ───────────────────────────────────────────────────────────────
# CloudWatch Log Group
# ───────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.environment == "prod" ? 90 : 7

  tags = {
    Name        = "${var.function_name}-logs"
    Environment = var.environment
  }
}

# ───────────────────────────────────────────────────────────────
# Archive du code source (si code inline)
# ───────────────────────────────────────────────────────────────

data "archive_file" "lambda" {
  count       = var.code_inline != "" ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content  = var.code_inline
    filename = "lambda_function.py"
  }
}

# ───────────────────────────────────────────────────────────────
# Fonction Lambda
# ───────────────────────────────────────────────────────────────

resource "aws_lambda_function" "main" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  
  # Code source
  filename         = var.code_inline != "" ? data.archive_file.lambda[0].output_path : var.code_zip_path
  source_code_hash = var.code_inline != "" ? data.archive_file.lambda[0].output_base64sha256 : filebase64sha256(var.code_zip_path)

  # Runtime
  runtime = var.runtime
  handler = var.handler

  # Configuration
  memory_size = var.memory_size
  timeout     = var.timeout

  # Variables d'environnement
  environment {
    variables = var.env_vars
  }

  # Logs
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_cloudwatch_log_group.lambda
  ]

  tags = {
    Name        = var.function_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Sonatel-IAC"
  }
}