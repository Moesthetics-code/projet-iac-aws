# ═══════════════════════════════════════════════════════════════════════════════
# AWS CodePipeline - Variables Terraform
# ═══════════════════════════════════════════════════════════════════════════════

# ── Configuration de Base ──────────────────────────────────────────────────
variable "pipeline_name" {
  description = "Nom du pipeline CodePipeline"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.pipeline_name))
    error_message = "Le nom du pipeline ne peut contenir que des alphanumériques, tirets et underscores."
  }
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "L'environnement doit être 'dev', 'staging' ou 'prod'."
  }
}

variable "region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}

variable "description" {
  description = "Description du pipeline"
  type        = string
  default     = ""
}

# ── Configuration Source ───────────────────────────────────────────────────
variable "source_provider" {
  description = "Provider source (GitHub, GitHubEnterprise, CodeCommit, S3, Bitbucket)"
  type        = string

  validation {
    condition     = contains(["GitHub", "GitHubEnterprise", "CodeCommit", "S3", "Bitbucket"], var.source_provider)
    error_message = "Provider source invalide."
  }
}

# GitHub / Bitbucket
variable "github_connection_arn" {
  description = "ARN de la connexion CodeStar pour GitHub/Bitbucket"
  type        = string
  default     = ""
}

variable "repository" {
  description = "Repository (format: owner/repo)"
  type        = string
  default     = ""
}

variable "branch" {
  description = "Branche Git"
  type        = string
  default     = "main"
}

# CodeCommit
variable "codecommit_repository_name" {
  description = "Nom du repository CodeCommit"
  type        = string
  default     = ""
}

variable "codecommit_branch" {
  description = "Branche CodeCommit"
  type        = string
  default     = "main"
}

# S3
variable "s3_source_bucket" {
  description = "Bucket S3 source"
  type        = string
  default     = ""
}

variable "s3_source_object_key" {
  description = "Clé de l'objet S3 source"
  type        = string
  default     = ""
}

# ── Configuration Build ────────────────────────────────────────────────────
variable "enable_build" {
  description = "Activer l'étape de build"
  type        = bool
  default     = true
}

variable "build_project_name" {
  description = "Nom du projet CodeBuild"
  type        = string
  default     = ""
}

variable "build_environment" {
  description = "Environnement de build"
  type        = string
  default     = "ubuntu-standard-7.0"
}

variable "build_compute_type" {
  description = "Type de compute pour le build"
  type        = string
  default     = "small"
}

variable "buildspec" {
  description = "Buildspec inline (optionnel)"
  type        = string
  default     = ""
}

variable "build_env_vars" {
  description = "Variables d'environnement pour le build"
  type        = map(string)
  default     = {}
}

variable "enable_build_cache" {
  description = "Activer le cache S3 pour le build"
  type        = bool
  default     = false
}

# ── Configuration Test ─────────────────────────────────────────────────────
variable "enable_test" {
  description = "Activer l'étape de test"
  type        = bool
  default     = false
}

variable "test_project_name" {
  description = "Nom du projet CodeBuild pour les tests"
  type        = string
  default     = ""
}

variable "test_type" {
  description = "Type de tests (integration, e2e, security, performance, custom)"
  type        = string
  default     = "integration"
}

# ── Configuration Approval ─────────────────────────────────────────────────
variable "manual_approval" {
  description = "Activer l'approbation manuelle"
  type        = bool
  default     = false
}

variable "approval_sns_topic_arn" {
  description = "ARN du topic SNS pour les approbations"
  type        = string
  default     = ""
}

variable "approvers" {
  description = "Liste des emails des approbateurs"
  type        = list(string)
  default     = []
}

# ── Configuration Deploy ───────────────────────────────────────────────────
variable "deploy_provider" {
  description = "Provider de déploiement (ECS, CodeDeploy, Lambda, S3, CloudFormation, EKS, Beanstalk)"
  type        = string

  validation {
    condition     = contains(["ECS", "ECS-BlueGreen", "CodeDeploy", "Lambda", "S3", "CloudFormation", "EKS", "Beanstalk"], var.deploy_provider)
    error_message = "Provider de déploiement invalide."
  }
}

# ECS
variable "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  type        = string
  default     = ""
}

variable "ecs_service_name" {
  description = "Nom du service ECS"
  type        = string
  default     = ""
}

variable "ecs_image_definition_file" {
  description = "Fichier de définition d'image ECS"
  type        = string
  default     = "imagedefinitions.json"
}

# CodeDeploy
variable "codedeploy_application_name" {
  description = "Nom de l'application CodeDeploy"
  type        = string
  default     = ""
}

variable "codedeploy_deployment_group_name" {
  description = "Nom du deployment group CodeDeploy"
  type        = string
  default     = ""
}

# Lambda
variable "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
  default     = ""
}

# S3
variable "s3_deploy_bucket" {
  description = "Bucket S3 de destination"
  type        = string
  default     = ""
}

variable "s3_extract_archive" {
  description = "Extraire l'archive dans S3"
  type        = bool
  default     = true
}

# ── Configuration Notifications ───────────────────────────────────────────
variable "enable_notifications" {
  description = "Activer les notifications SNS"
  type        = bool
  default     = false
}

variable "notification_sns_topic_arn" {
  description = "ARN du topic SNS pour les notifications"
  type        = string
  default     = ""
}

variable "notification_events" {
  description = "Types d'événements à notifier"
  type        = list(string)
  default     = ["STARTED", "SUCCEEDED", "FAILED"]
}

variable "enable_cloudwatch_alarms" {
  description = "Activer les alarmes CloudWatch"
  type        = bool
  default     = false
}

# ── Tags & Métadonnées ─────────────────────────────────────────────────────
variable "tags" {
  description = "Tags AWS à appliquer aux ressources"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Propriétaire / Équipe"
  type        = string
  default     = ""
}

variable "cost_center" {
  description = "Centre de coûts"
  type        = string
  default     = ""
}
