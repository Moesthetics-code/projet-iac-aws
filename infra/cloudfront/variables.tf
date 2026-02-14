# ═══════════════════════════════════════════════════════════════
# CLOUDFRONT - variables.tf
# ═══════════════════════════════════════════════════════════════

variable "origin_domain" {
  description = "Domaine d'origine"
  type        = string
}

variable "origin_type" {
  description = "Type d'origine (s3/custom)"
  type        = string
  default     = "s3"
  
  validation {
    condition     = contains(["s3", "custom"], var.origin_type)
    error_message = "Le type doit être s3 ou custom."
  }
}

variable "distribution_comment" {
  description = "Description de la distribution"
  type        = string
  default     = ""
}

variable "aliases" {
  description = "Domaines alternatifs (CNAME)"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ARN du certificat ACM (us-east-1)"
  type        = string
  default     = ""
}

variable "default_ttl" {
  description = "TTL par défaut en secondes"
  type        = number
  default     = 86400
}

variable "price_class" {
  description = "Price Class"
  type        = string
  default     = "PriceClass_100"
}

variable "compress" {
  description = "Activer la compression"
  type        = bool
  default     = true
}

variable "ipv6" {
  description = "Activer IPv6"
  type        = bool
  default     = true
}

variable "logging" {
  description = "Activer les logs"
  type        = bool
  default     = false
}

variable "viewer_protocol_policy" {
  description = "Politique de protocole"
  type        = string
  default     = "redirect-to-https"
}
