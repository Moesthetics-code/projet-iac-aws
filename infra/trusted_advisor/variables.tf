variable "notification_email" {
  description = "Email pour notifications"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags AWS"
  type        = map(string)
  default     = {}
}
