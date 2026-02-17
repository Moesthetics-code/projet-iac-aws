# ═══════════════════════════════════════════════════════════════════════════════
# AWS CodeBuild - Variables Terraform
# ═══════════════════════════════════════════════════════════════════════════════

# ── Configuration de Base ──────────────────────────────────────────────────
variable "project_name" {
  description = "Nom du projet CodeBuild"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.project_name))
    error_message = "Le nom du projet ne peut contenir que des alphanumériques, tirets et underscores."
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
  description = "Description du projet"
  type        = string
  default     = ""
}

# ── Configuration Source ───────────────────────────────────────────────────
variable "source_type" {
  description = "Type de source (CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET, S3, NO_SOURCE)"
  type        = string

  validation {
    condition     = contains(["CODECOMMIT", "CODEPIPELINE", "GITHUB", "GITHUB_ENTERPRISE", "BITBUCKET", "S3", "NO_SOURCE"], var.source_type)
    error_message = "Type de source invalide."
  }
}

variable "source_location" {
  description = "Emplacement de la source (URL du repo, ARN S3, etc.)"
  type        = string
  default     = ""
}

variable "source_version" {
  description = "Version/branche de la source"
  type        = string
  default     = "main"
}

variable "git_clone_depth" {
  description = "Profondeur du clone Git (0 = clone complet)"
  type        = number
  default     = 1
}

variable "fetch_git_submodules" {
  description = "Récupérer les sous-modules Git"
  type        = bool
  default     = false
}

variable "secondary_sources" {
  description = "Sources secondaires pour le build"
  type = list(object({
    type       = string
    location   = string
    identifier = string
  }))
  default = []
}

# ── Configuration Environnement Build ──────────────────────────────────────
variable "environment_type" {
  description = "Type d'environnement"
  type        = string
  default     = "LINUX_CONTAINER"

  validation {
    condition     = contains(["LINUX_CONTAINER", "LINUX_GPU_CONTAINER", "ARM_CONTAINER", "WINDOWS_CONTAINER", "WINDOWS_SERVER_2019_CONTAINER"], var.environment_type)
    error_message = "Type d'environnement invalide."
  }
}

variable "image" {
  description = "Image Docker pour le build"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "custom_image" {
  description = "URI d'une image personnalisée (si image = CUSTOM)"
  type        = string
  default     = ""
}

variable "compute_type" {
  description = "Type de compute"
  type        = string
  default     = "BUILD_GENERAL1_MEDIUM"

  validation {
    condition     = contains(["BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM", "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_2XLARGE"], var.compute_type)
    error_message = "Type de compute invalide."
  }
}

variable "privileged_mode" {
  description = "Mode privilégié (nécessaire pour Docker)"
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Variables d'environnement pour le build"
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "PLAINTEXT")
  }))
  default = []
}

# ── Configuration Buildspec ────────────────────────────────────────────────
variable "buildspec_type" {
  description = "Type de buildspec (file ou inline)"
  type        = string
  default     = "file"

  validation {
    condition     = contains(["file", "inline"], var.buildspec_type)
    error_message = "Le type de buildspec doit être 'file' ou 'inline'."
  }
}

variable "buildspec" {
  description = "Buildspec inline (si buildspec_type = inline)"
  type        = string
  default     = ""
}

variable "buildspec_path" {
  description = "Chemin du fichier buildspec dans le repo"
  type        = string
  default     = "buildspec.yml"
}

# ── Configuration Artifacts ────────────────────────────────────────────────
variable "artifacts_type" {
  description = "Type d'artifacts (NO_ARTIFACTS, S3, CODEPIPELINE)"
  type        = string
  default     = "NO_ARTIFACTS"

  validation {
    condition     = contains(["NO_ARTIFACTS", "S3", "CODEPIPELINE"], var.artifacts_type)
    error_message = "Type d'artifacts invalide."
  }
}

variable "artifacts_bucket" {
  description = "Bucket S3 pour les artifacts"
  type        = string
  default     = ""
}

variable "artifacts_path" {
  description = "Chemin dans le bucket S3"
  type        = string
  default     = ""
}

variable "artifacts_packaging" {
  description = "Type de packaging (NONE ou ZIP)"
  type        = string
  default     = "NONE"
}

# ── Configuration Cache ────────────────────────────────────────────────────
variable "enable_cache" {
  description = "Activer le cache S3"
  type        = bool
  default     = false
}

variable "cache_bucket" {
  description = "Bucket S3 pour le cache"
  type        = string
  default     = ""
}

variable "cache_paths" {
  description = "Chemins à mettre en cache"
  type        = list(string)
  default     = []
}

# ── Configuration Logs ─────────────────────────────────────────────────────
variable "cloudwatch_logs_enabled" {
  description = "Activer les logs CloudWatch"
  type        = bool
  default     = true
}

variable "logs_retention_days" {
  description = "Durée de rétention des logs CloudWatch (jours)"
  type        = number
  default     = 7
}

variable "s3_logs_enabled" {
  description = "Activer les logs S3"
  type        = bool
  default     = false
}

variable "s3_logs_bucket" {
  description = "Bucket S3 pour les logs"
  type        = string
  default     = ""
}

# ── Configuration Timeouts ─────────────────────────────────────────────────
variable "timeout_minutes" {
  description = "Timeout du build en minutes"
  type        = number
  default     = 60

  validation {
    condition     = var.timeout_minutes >= 5 && var.timeout_minutes <= 480
    error_message = "Le timeout doit être entre 5 et 480 minutes."
  }
}

variable "queued_timeout_minutes" {
  description = "Timeout en file d'attente en minutes"
  type        = number
  default     = 480

  validation {
    condition     = var.queued_timeout_minutes >= 5 && var.queued_timeout_minutes <= 480
    error_message = "Le queued timeout doit être entre 5 et 480 minutes."
  }
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

variable "notification_emails" {
  description = "Liste des emails pour les notifications"
  type        = list(string)
  default     = []
}

# ── Configuration GitHub Webhook ───────────────────────────────────────────
variable "enable_github_webhook" {
  description = "Activer le webhook GitHub"
  type        = bool
  default     = false
}

variable "webhook_branch_filter" {
  description = "Pattern de filtrage pour les branches du webhook"
  type        = string
  default     = "^refs/heads/main$"
}

# ── Tags & Métadonnées ─────────────────────────────────────────────────────
variable "tags" {
  description = "Tags AWS à appliquer aux ressources"
  type        = map(string)
  default     = {}
}
