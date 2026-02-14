# ═══════════════════════════════════════════════════════════════
# TERRAFORM EC2 - Variables
# ═══════════════════════════════════════════════════════════════

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "instance_name" {
  description = "Nom de l'instance EC2"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.instance_name))
    error_message = "Le nom doit contenir uniquement des lettres, chiffres, tirets et underscores."
  }
}

variable "instance_os" {
  description = "AMI ID pour l'instance"
  type        = string
  
  validation {
    condition     = can(regex("^ami-", var.instance_os))
    error_message = "L'AMI doit commencer par 'ami-'."
  }
}

variable "instance_size" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium", "t2.micro", "t2.small"], var.instance_size)
    error_message = "Le type d'instance doit être l'un des suivants: t3.micro, t3.small, t3.medium, t2.micro, t2.small."
  }
}

variable "instance_env" {
  description = "Environnement de déploiement"
  type        = string
  
  validation {
    condition     = contains(["dev", "preprod", "prod"], var.instance_env)
    error_message = "L'environnement doit être dev, preprod ou prod."
  }
}
