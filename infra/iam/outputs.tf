# ═══════════════════════════════════════════════════════════════
# IAM - outputs.tf
# ═══════════════════════════════════════════════════════════════

output "user_arn" {
  description = "ARN de l'utilisateur"
  value       = var.resource_type == "user" ? aws_iam_user.main[0].arn : null
}

output "group_arn" {
  description = "ARN du groupe"
  value       = var.resource_type == "group" ? aws_iam_group.main[0].arn : null
}

output "role_arn" {
  description = "ARN du rôle"
  value       = var.resource_type == "role" ? aws_iam_role.main[0].arn : null
}

output "policy_arn" {
  description = "ARN de la policy"
  value       = var.resource_type == "policy" ? aws_iam_policy.main[0].arn : null
}

