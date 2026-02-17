variable "report_name" {
  description = "Nom du rapport"
  type        = string
  default     = "monthly-cost-report"
}

variable "enable_reports" {
  description = "Activer rapports automatiques"
  type        = bool
  default     = false
}

variable "report_email" {
  description = "Email pour rapports"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags AWS"
  type        = map(string)
  default     = {}
}
