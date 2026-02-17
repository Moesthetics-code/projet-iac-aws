variable "budget_name" {
  description = "Nom du budget"
  type        = string
}

variable "budget_amount" {
  description = "Montant du budget (USD)"
  type        = string
}

variable "time_unit" {
  description = "Période (MONTHLY, QUARTERLY, ANNUALLY)"
  type        = string
  default     = "MONTHLY"
}

variable "alert_thresholds" {
  description = "Seuils d'alerte"
  type = list(object({
    threshold = number
    emails    = list(string)
  }))
}

variable "tags" {
  description = "Tags AWS"
  type        = map(string)
  default     = {}
}
