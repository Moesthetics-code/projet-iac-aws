# ═══════════════════════════════════════════════════════════════
# TERRAFORM LAMBDA - outputs.tf
# ═══════════════════════════════════════════════════════════════

output "function_arn" {
  description = "ARN de la fonction Lambda"
  value       = aws_lambda_function.main.arn
}

output "function_name" {
  description = "Nom de la fonction"
  value       = aws_lambda_function.main.function_name
}

output "invoke_arn" {
  description = "ARN pour invoquer la fonction"
  value       = aws_lambda_function.main.invoke_arn
}

output "version" {
  description = "Version de la fonction"
  value       = aws_lambda_function.main.version
}

output "log_group_name" {
  description = "Nom du groupe de logs CloudWatch"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "role_arn" {
  description = "ARN du rôle IAM"
  value       = aws_iam_role.lambda.arn
}
