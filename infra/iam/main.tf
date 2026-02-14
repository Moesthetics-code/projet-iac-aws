# ═══════════════════════════════════════════════════════════════
# IAM - main.tf
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

# User IAM
resource "aws_iam_user" "main" {
  count = var.resource_type == "user" ? 1 : 0
  name  = var.resource_name
  path  = var.path

  tags = {
    Name      = var.resource_name
    ManagedBy = "Terraform"
  }
}

# Group IAM
resource "aws_iam_group" "main" {
  count = var.resource_type == "group" ? 1 : 0
  name  = var.resource_name
  path  = var.path
}

# Role IAM
resource "aws_iam_role" "main" {
  count = var.resource_type == "role" ? 1 : 0
  name  = var.resource_name
  path  = var.path

  assume_role_policy = var.assume_role_policy

  tags = {
    Name      = var.resource_name
    ManagedBy = "Terraform"
  }
}

# Policy IAM
resource "aws_iam_policy" "main" {
  count  = var.resource_type == "policy" ? 1 : 0
  name   = var.resource_name
  path   = var.path
  policy = var.policy_document
}

# Attachement policies managées (User)
resource "aws_iam_user_policy_attachment" "managed_user" {
  count      = var.resource_type == "user" ? length(var.managed_policies) : 0
  user       = aws_iam_user.main[0].name
  policy_arn = var.managed_policies[count.index]
}

# Attachement policies managées (Group)
resource "aws_iam_group_policy_attachment" "managed_group" {
  count      = var.resource_type == "group" ? length(var.managed_policies) : 0
  group      = aws_iam_group.main[0].name
  policy_arn = var.managed_policies[count.index]
}

# Attachement policies managées (Role)
resource "aws_iam_role_policy_attachment" "managed_role" {
  count      = var.resource_type == "role" ? length(var.managed_policies) : 0
  role       = aws_iam_role.main[0].name
  policy_arn = var.managed_policies[count.index]
}

# Policy inline (User)
resource "aws_iam_user_policy" "inline" {
  count  = var.resource_type == "user" && var.inline_policy != "" ? 1 : 0
  name   = "${var.resource_name}-inline"
  user   = aws_iam_user.main[0].name
  policy = var.inline_policy
}
