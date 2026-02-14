# ═══════════════════════════════════════════════════════════════
# ROUTE 53 - variables.tf
# ═══════════════════════════════════════════════════════════════

variable "zone_name" {
  description = "Nom de domaine"
  type        = string
}

variable "zone_type" {
  description = "Type de zone (public/private)"
  type        = string
  default     = "public"
  
  validation {
    condition     = contains(["public", "private"], var.zone_type)
    error_message = "Le type doit être public ou private."
  }
}

variable "vpc_id" {
  description = "VPC ID (pour zone private)"
  type        = string
  default     = ""
}

variable "record_name" {
  description = "Nom de l'enregistrement"
  type        = string
  default     = ""
}

variable "record_type" {
  description = "Type d'enregistrement"
  type        = string
  default     = "A"
  
  validation {
    condition     = contains(["A", "AAAA", "CNAME", "MX", "TXT", "NS"], var.record_type)
    error_message = "Type d'enregistrement invalide."
  }
}

variable "record_value" {
  description = "Valeur de l'enregistrement"
  type        = string
  default     = ""
}

variable "ttl" {
  description = "TTL en secondes"
  type        = number
  default     = 300
}

variable "routing_policy" {
  description = "Politique de routage"
  type        = string
  default     = "simple"
}

variable "enable_health_check" {
  description = "Activer health check"
  type        = bool
  default     = false
}