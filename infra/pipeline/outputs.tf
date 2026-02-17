# ═══════════════════════════════════════════════════════════════════════════════
# AWS CodePipeline - Outputs Terraform
# ═══════════════════════════════════════════════════════════════════════════════

output "pipeline_id" {
  description = "ID du pipeline"
  value       = aws_codepipeline.main.id
}

output "pipeline_arn" {
  description = "ARN du pipeline"
  value       = aws_codepipeline.main.arn
}

output "pipeline_name" {
  description = "Nom du pipeline"
  value       = aws_codepipeline.main.name
}

output "artifacts_bucket_name" {
  description = "Nom du bucket S3 des artifacts"
  value       = aws_s3_bucket.pipeline_artifacts.bucket
}

output "artifacts_bucket_arn" {
  description = "ARN du bucket S3 des artifacts"
  value       = aws_s3_bucket.pipeline_artifacts.arn
}

output "pipeline_role_arn" {
  description = "ARN du rôle IAM du pipeline"
  value       = aws_iam_role.codepipeline_role.arn
}

output "pipeline_role_name" {
  description = "Nom du rôle IAM du pipeline"
  value       = aws_iam_role.codepipeline_role.name
}

output "notification_topic_arn" {
  description = "ARN du topic SNS pour les notifications"
  value       = var.enable_notifications ? aws_sns_topic.pipeline_notifications[0].arn : null
}

output "pipeline_url" {
  description = "URL de la console AWS pour le pipeline"
  value       = "https://${var.region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.main.name}/view"
}

output "pipeline_stages" {
  description = "Liste des étapes du pipeline"
  value = concat(
    ["Source"],
    var.enable_build ? ["Build"] : [],
    var.enable_test ? ["Test"] : [],
    var.manual_approval ? ["Approval"] : [],
    ["Deploy"]
  )
}

output "pipeline_configuration" {
  description = "Configuration complète du pipeline"
  value = {
    name              = aws_codepipeline.main.name
    environment       = var.environment
    source_provider   = var.source_provider
    deploy_provider   = var.deploy_provider
    build_enabled     = var.enable_build
    test_enabled      = var.enable_test
    approval_required = var.manual_approval
    notifications_enabled = var.enable_notifications
  }
}
