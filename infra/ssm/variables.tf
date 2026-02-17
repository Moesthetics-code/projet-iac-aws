# AWS Systems Manager - Variables
variable "environment" {
  description = "Environnement"
  type        = string
}

variable "region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}

variable "namespace" {
  description = "Namespace pour les paramètres"
  type        = string
}

variable "parameters" {
  description = "Liste des paramètres à créer"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
}

variable "use_advanced_tier" {
  description = "Utiliser le tier Advanced"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS Key ID pour SecureString"
  type        = string
  default     = ""
}

variable "enable_session_manager" {
  description = "Activer Session Manager"
  type        = bool
  default     = true
}

variable "session_logging" {
  description = "Type de logging (disabled, cloudwatch, s3, both)"
  type        = string
  default     = "disabled"
}

variable "s3_bucket_logs" {
  description = "Bucket S3 pour les logs"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags AWS"
  type        = map(string)
  default     = {}
}
