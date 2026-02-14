# ═══════════════════════════════════════════════════════════════
# RDS - variables.tf
# ═══════════════════════════════════════════════════════════════

variable "db_identifier" {
  description = "Identifiant unique de la base de données"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9\\-]*$", var.db_identifier))
    error_message = "L'identifiant doit commencer par une lettre et contenir uniquement des minuscules, chiffres et tirets."
  }
}

variable "engine" {
  description = "Moteur de base de données"
  type        = string
  
  validation {
    condition     = contains(["mysql", "postgres", "mariadb"], var.engine)
    error_message = "Le moteur doit être mysql, postgres ou mariadb."
  }
}

variable "engine_version" {
  description = "Version du moteur"
  type        = string
}

variable "instance_class" {
  description = "Classe de l'instance"
  type        = string
  default     = "db.t3.micro"
  
  validation {
    condition     = can(regex("^db\\.", var.instance_class))
    error_message = "La classe d'instance doit commencer par 'db.'."
  }
}

variable "allocated_storage" {
  description = "Stockage alloué en GB"
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 65536
    error_message = "Le stockage doit être entre 20 et 65536 GB."
  }
}

variable "db_name" {
  description = "Nom de la base de données initiale"
  type        = string
  default     = ""
}

variable "username" {
  description = "Nom d'utilisateur master"
  type        = string

  validation {
    condition     = length(var.username) >= 3 && length(var.username) <= 16
    error_message = "Le nom d'utilisateur doit contenir entre 3 et 16 caractères."
  }
}

variable "password" {
  description = "Mot de passe master"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.password) >= 8
    error_message = "Le mot de passe doit contenir au moins 8 caractères."
  }
}

variable "multi_az" {
  description = "Activer Multi-AZ pour haute disponibilité"
  type        = bool
  default     = false
}

variable "backup_retention" {
  description = "Période de rétention des backups (jours)"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention >= 0 && var.backup_retention <= 35
    error_message = "La rétention doit être entre 0 et 35 jours."
  }
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  
  validation {
    condition     = contains(["dev", "preprod", "prod"], var.environment)
    error_message = "L'environnement doit être dev, preprod ou prod."
  }
}