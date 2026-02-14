# ─────────────────────────────────────────────────────────────────────────────
#  variables.tf — PROJET IAC SONATEL · S3 Static Website Deployer
# ─────────────────────────────────────────────────────────────────────────────

variable "region" {
  description = "Région AWS cible pour le bucket S3"
  type        = string
  default     = "eu-west-3"

  validation {
    condition = contains([
      "eu-west-3", "eu-north-1", "us-east-1", "us-west-2"
    ], var.region)
    error_message = "Région non supportée. Valeurs autorisées: eu-west-3, eu-north-1, us-east-1, us-west-2."
  }
}

variable "bucket_name" {
  description = "Nom globalement unique du compartiment S3"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9\\-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Le nom du bucket doit : contenir 3-63 caractères, commencer/finir par un alphanumérique, n'utiliser que des minuscules, chiffres et tirets."
  }

  validation {
    condition     = !can(regex("--", var.bucket_name))
    error_message = "Le nom du bucket ne peut pas contenir deux tirets consécutifs (--)."
  }

  validation {
    condition     = !can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+$", var.bucket_name))
    error_message = "Le nom du bucket ne peut pas ressembler à une adresse IP (ex: 192.168.1.1)."
  }
}

variable "bucket_env" {
  description = "Environnement de déploiement (pour le tagging et les politiques)"
  type        = string

  validation {
    condition     = contains(["dev", "preprod", "prod"], var.bucket_env)
    error_message = "L'environnement doit être: dev, preprod ou prod."
  }
}

variable "index_document" {
  description = "Document HTML servi à la racine du site web statique"
  type        = string
  default     = "index.html"

  validation {
    condition     = can(regex("\\.html?$", var.index_document))
    error_message = "Le document index doit être un fichier HTML (.html ou .htm)."
  }
}

variable "error_document" {
  description = "Document HTML affiché en cas d'erreur 404"
  type        = string
  default     = "error.html"
}

variable "storage_class" {
  description = "Classe de stockage S3 pour les objets du site"
  type        = string
  default     = "STANDARD"

  validation {
    condition = contains([
      "STANDARD",
      "STANDARD_IA",
      "ONEZONE_IA",
      "INTELLIGENT_TIERING",
      "GLACIER",
      "DEEP_ARCHIVE"
    ], var.storage_class)
    error_message = "Classe de stockage invalide."
  }
}

variable "enable_versioning" {
  description = "État du versioning du bucket (Enabled, Suspended, Disabled)"
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.enable_versioning)
    error_message = "Le versioning doit être: Enabled, Suspended ou Disabled."
  }
}

# ── Contrôle d'accès public ───────────────────────────────────────────────
# IMPORTANT: Ces 4 variables DOIVENT être false pour héberger un site web
# statique public sur S3. Terraform applique aws_s3_bucket_public_access_block
# avec ces valeurs.

variable "block_public_acls" {
  description = <<-EOT
    Bloquer les ACL publiques (block_public_acls).
    DOIT être false pour les sites web statiques publics.
  EOT
  type    = bool
  default = false
}

variable "block_public_policy" {
  description = <<-EOT
    Bloquer les politiques de bucket publiques (block_public_policy).
    DOIT être false pour permettre la bucket policy GetObject.
  EOT
  type    = bool
  default = false
}

variable "ignore_public_acls" {
  description = <<-EOT
    Ignorer les ACL publiques (ignore_public_acls).
    DOIT être false pour les sites web statiques publics.
  EOT
  type    = bool
  default = false
}

variable "restrict_public_buckets" {
  description = <<-EOT
    Restreindre les buckets publics (restrict_public_buckets).
    DOIT être false pour autoriser l'hébergement web statique.
  EOT
  type    = bool
  default = false
}

# ── Chemins des fichiers à uploader ──────────────────────────────────────
variable "site_source_dir" {
  description = "Répertoire local contenant les fichiers du site web statique à uploader"
  type        = string
  default     = "./site"
}
