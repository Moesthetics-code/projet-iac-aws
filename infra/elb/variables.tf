# ═══════════════════════════════════════════════════════════════
# ELB - variables.tf
# ═══════════════════════════════════════════════════════════════

variable "lb_name" {
  description = "Nom du Load Balancer"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]+$", var.lb_name)) && length(var.lb_name) <= 32
    error_message = "Le nom doit contenir uniquement lettres, chiffres et tirets (max 32 caractères)."
  }
}

variable "lb_type" {
  description = "Type de Load Balancer"
  type        = string
  default     = "application"
  
  validation {
    condition     = contains(["application", "network"], var.lb_type)
    error_message = "Le type doit être application ou network."
  }
}

variable "scheme" {
  description = "Schéma du LB"
  type        = string
  default     = "internet-facing"
}

variable "subnet_ids" {
  description = "IDs des subnets"
  type        = list(string)
  default     = []
}

variable "target_group_port" {
  description = "Port du target group"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Path du health check"
  type        = string
  default     = "/"
}

variable "healthy_threshold" {
  description = "Seuil healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Seuil unhealthy"
  type        = number
  default     = 2
}

variable "health_check_timeout" {
  description = "Timeout health check"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Intervalle health check"
  type        = number
  default     = 30
}

variable "http_action" {
  description = "Action HTTP (forward/redirect)"
  type        = string
  default     = "forward"
}

variable "ssl_certificate_arn" {
  description = "ARN du certificat SSL"
  type        = string
  default     = ""
}
