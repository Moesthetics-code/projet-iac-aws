# ═══════════════════════════════════════════════════════════════
# CLOUDWATCH - variables.tf
# ═══════════════════════════════════════════════════════════════

variable "alarm_name" {
  description = "Nom de l'alarme"
  type        = string
}

variable "alarm_description" {
  description = "Description de l'alarme"
  type        = string
  default     = ""
}

variable "metric_name" {
  description = "Nom de la métrique"
  type        = string
}

variable "namespace" {
  description = "Namespace AWS"
  type        = string
}

variable "threshold" {
  description = "Seuil d'alerte"
  type        = number
}

variable "comparison_operator" {
  description = "Opérateur de comparaison"
  type        = string
  default     = "GreaterThanThreshold"
}

variable "evaluation_periods" {
  description = "Nombre de périodes d'évaluation"
  type        = number
  default     = 2
}

variable "period" {
  description = "Période en secondes"
  type        = number
  default     = 300
}

variable "statistic" {
  description = "Statistique"
  type        = string
  default     = "Average"
}

variable "sns_topic_arn" {
  description = "ARN du topic SNS"
  type        = string
  default     = ""
}
