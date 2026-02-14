# ═══════════════════════════════════════════════════════════════
# IAM - variables.tf
# ═══════════════════════════════════════════════════════════════

variable "resource_type" {
  description = "Type de ressource IAM"
  type        = string
  
  validation {
    condition     = contains(["user", "group", "role", "policy"], var.resource_type)
    error_message = "Le type doit être user, group, role ou policy."
  }
}

variable "resource_name" {
  description = "Nom de la ressource"
  type        = string
}

variable "path" {
  description = "Path IAM"
  type        = string
  default     = "/"
}

variable "managed_policies" {
  description = "ARNs des policies AWS managées"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Policy inline en JSON"
  type        = string
  default     = ""
}

variable "policy_document" {
  description = "Document de policy (pour type=policy)"
  type        = string
  default     = ""
}

variable "assume_role_policy" {
  description = "Assume role policy (pour type=role)"
  type        = string
  default     = ""
}
