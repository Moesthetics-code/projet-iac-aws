# AWS CodeDeploy - Variables Terraform

variable "application_name" {
  description = "Nom de l'application CodeDeploy"
  type        = string
}

variable "compute_platform" {
  description = "Plateforme (Server, Lambda, ECS)"
  type        = string
  validation {
    condition     = contains(["Server", "Lambda", "ECS"], var.compute_platform)
    error_message = "Plateforme invalide."
  }
}

variable "region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environnement"
  type        = string
}

variable "deployment_group_name" {
  description = "Nom du deployment group"
  type        = string
}

variable "deployment_config_name" {
  description = "Configuration de déploiement"
  type        = string
  default     = "CodeDeployDefault.OneAtATime"
}

# EC2/Server
variable "ec2_tag_filters" {
  description = "Tags pour cibler les instances EC2"
  type = list(object({
    key   = string
    type  = string
    value = string
  }))
  default = []
}

variable "autoscaling_groups" {
  description = "Noms des Auto Scaling Groups"
  type        = list(string)
  default     = []
}

# Lambda
variable "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
  default     = ""
}

variable "lambda_alias" {
  description = "Alias Lambda"
  type        = string
  default     = "live"
}

# ECS
variable "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  type        = string
  default     = ""
}

variable "ecs_service_name" {
  description = "Nom du service ECS"
  type        = string
  default     = ""
}

# Blue/Green
variable "blue_green_enabled" {
  description = "Activer Blue/Green"
  type        = bool
  default     = false
}

variable "green_fleet_option" {
  description = "Option fleet Green"
  type        = string
  default     = "COPY_AUTO_SCALING_GROUP"
}

variable "terminate_blue_instances" {
  description = "Action après basculement"
  type        = string
  default     = "TERMINATE"
}

variable "blue_green_timeout" {
  description = "Timeout Blue/Green (minutes)"
  type        = number
  default     = 60
}

# Rollback
variable "auto_rollback_enabled" {
  description = "Activer rollback auto"
  type        = bool
  default     = true
}

variable "auto_rollback_events" {
  description = "Events pour rollback"
  type        = list(string)
  default     = ["DEPLOYMENT_FAILURE"]
}

variable "rollback_on_alarm" {
  description = "Rollback sur alarme"
  type        = bool
  default     = false
}

variable "cloudwatch_alarms" {
  description = "Noms des alarmes CloudWatch"
  type        = list(string)
  default     = []
}

# Load Balancer
variable "use_load_balancer" {
  description = "Utiliser un load balancer"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Type de load balancer"
  type        = string
  default     = "target_group"
}

variable "target_group_name" {
  description = "Nom du target group"
  type        = string
  default     = ""
}

variable "classic_lb_name" {
  description = "Nom du classic load balancer"
  type        = string
  default     = ""
}

# Notifications
variable "enable_notifications" {
  description = "Activer les notifications"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags AWS"
  type        = map(string)
  default     = {}
}
