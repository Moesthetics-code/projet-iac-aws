# ═══════════════════════════════════════════════════════════════
# TERRAFORM LAMBDA - variables.tf
# ═══════════════════════════════════════════════════════════════

variable "function_name" {
  description = "Nom de la fonction Lambda"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.function_name))
    error_message = "Le nom doit contenir uniquement lettres, chiffres, tirets et underscores."
  }
}

variable "runtime" {
  description = "Runtime de la fonction"
  type        = string
  
  validation {
    condition = contains([
      "python3.11", "python3.10", "python3.9",
      "nodejs20.x", "nodejs18.x",
      "java17", "go1.x", "dotnet7", "ruby3.2"
    ], var.runtime)
    error_message = "Runtime non supporté."
  }
}

variable "handler" {
  description = "Point d'entrée de la fonction"
  type        = string
}

variable "memory_size" {
  description = "Mémoire allouée en MB"
  type        = number
  default     = 512

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "La mémoire doit être entre 128 et 10240 MB."
  }
}

variable "timeout" {
  description = "Timeout en secondes"
  type        = number
  default     = 30

  validation {
    condition     = var.timeout >= 3 && var.timeout <= 900
    error_message = "Le timeout doit être entre 3 et 900 secondes."
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

variable "code_inline" {
  description = "Code source inline (Python/Node.js)"
  type        = string
  default     = ""
}

variable "code_zip_path" {
  description = "Chemin vers le fichier ZIP"
  type        = string
  default     = ""
}

variable "env_vars" {
  description = "Variables d'environnement"
  type        = map(string)
  default     = {}
}
