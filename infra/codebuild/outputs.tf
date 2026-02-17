# ═══════════════════════════════════════════════════════════════════════════════
# AWS CodeBuild - Outputs Terraform
# ═══════════════════════════════════════════════════════════════════════════════

output "project_id" {
  description = "ID du projet CodeBuild"
  value       = aws_codebuild_project.main.id
}

output "project_arn" {
  description = "ARN du projet CodeBuild"
  value       = aws_codebuild_project.main.arn
}

output "project_name" {
  description = "Nom du projet CodeBuild"
  value       = aws_codebuild_project.main.name
}

output "service_role_arn" {
  description = "ARN du rôle IAM"
  value       = aws_iam_role.codebuild_role.arn
}

output "service_role_name" {
  description = "Nom du rôle IAM"
  value       = aws_iam_role.codebuild_role.name
}

output "log_group_name" {
  description = "Nom du groupe de logs CloudWatch"
  value       = var.cloudwatch_logs_enabled ? aws_cloudwatch_log_group.codebuild_logs[0].name : null
}

output "log_group_arn" {
  description = "ARN du groupe de logs CloudWatch"
  value       = var.cloudwatch_logs_enabled ? aws_cloudwatch_log_group.codebuild_logs[0].arn : null
}

output "webhook_url" {
  description = "URL du webhook GitHub"
  value       = var.enable_github_webhook && (var.source_type == "GITHUB" || var.source_type == "GITHUB_ENTERPRISE") ? aws_codebuild_webhook.github[0].payload_url : null
}

output "webhook_secret" {
  description = "Secret du webhook GitHub"
  value       = var.enable_github_webhook && (var.source_type == "GITHUB" || var.source_type == "GITHUB_ENTERPRISE") ? aws_codebuild_webhook.github[0].secret : null
  sensitive   = true
}

output "console_url" {
  description = "URL de la console AWS pour le projet"
  value       = "https://${var.region}.console.aws.amazon.com/codesuite/codebuild/projects/${aws_codebuild_project.main.name}"
}

output "project_configuration" {
  description = "Configuration complète du projet"
  value = {
    name             = aws_codebuild_project.main.name
    environment      = var.environment
    source_type      = var.source_type
    compute_type     = var.compute_type
    image            = var.image
    privileged_mode  = var.privileged_mode
    cache_enabled    = var.enable_cache
    artifacts_type   = var.artifacts_type
    timeout_minutes  = var.timeout_minutes
  }
}
