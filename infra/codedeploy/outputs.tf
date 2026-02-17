# AWS CodeDeploy - Outputs Terraform

output "application_id" {
  description = "ID de l'application"
  value       = aws_codedeploy_app.main.id
}

output "application_arn" {
  description = "ARN de l'application"
  value       = aws_codedeploy_app.main.arn
}

output "application_name" {
  description = "Nom de l'application"
  value       = aws_codedeploy_app.main.name
}

output "deployment_group_id" {
  description = "ID du deployment group"
  value       = aws_codedeploy_deployment_group.main.id
}

output "deployment_group_arn" {
  description = "ARN du deployment group"
  value       = aws_codedeploy_deployment_group.main.arn
}

output "service_role_arn" {
  description = "ARN du rôle IAM"
  value       = aws_iam_role.codedeploy_role.arn
}

output "console_url" {
  description = "URL de la console AWS"
  value       = "https://${var.region}.console.aws.amazon.com/codesuite/codedeploy/applications/${aws_codedeploy_app.main.name}"
}

output "deployment_config" {
  description = "Configuration de déploiement"
  value = {
    platform           = var.compute_platform
    config_name        = var.deployment_config_name
    blue_green_enabled = var.blue_green_enabled
    auto_rollback      = var.auto_rollback_enabled
  }
}
