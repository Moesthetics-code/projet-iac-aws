# AWS Systems Manager - Outputs
output "parameter_names" {
  description = "Noms des paramètres créés"
  value       = [for p in aws_ssm_parameter.parameters : p.name]
}

output "parameter_arns" {
  description = "ARNs des paramètres"
  value       = [for p in aws_ssm_parameter.parameters : p.arn]
}

output "ssm_role_arn" {
  description = "ARN du rôle IAM SSM"
  value       = var.enable_session_manager ? aws_iam_role.ssm_role[0].arn : null
}

output "instance_profile_name" {
  description = "Nom du profil d'instance"
  value       = var.enable_session_manager ? aws_iam_instance_profile.ssm_profile[0].name : null
}

output "session_log_group" {
  description = "Groupe de logs CloudWatch"
  value       = var.enable_session_manager && (var.session_logging == "cloudwatch" || var.session_logging == "both") ? aws_cloudwatch_log_group.session_logs[0].name : null
}

output "console_url" {
  description = "URL de la console"
  value       = "https://${var.region}.console.aws.amazon.com/systems-manager/parameters"
}
