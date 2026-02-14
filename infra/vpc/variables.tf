# ═══════════════════════════════════════════════════════════════
# VPC - variables.tf
# ═══════════════════════════════════════════════════════════════

variable "vpc_name" {
  description = "Nom du VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Nombre de zones AZ"
  type        = number
  default     = 2
  
  validation {
    condition     = var.availability_zones >= 2 && var.availability_zones <= 3
    error_message = "Le nombre de zones doit être 2 ou 3."
  }
}

variable "enable_nat_gateway" {
  description = "Activer NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Activer VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Activer DNS hostnames"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Activer VPC Flow Logs"
  type        = bool
  default     = false
}
