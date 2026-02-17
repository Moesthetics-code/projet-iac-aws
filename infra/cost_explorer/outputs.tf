output "policy_arn" {
  description = "ARN de la policy IAM"
  value       = aws_iam_policy.cost_explorer.arn
}

output "console_url" {
  description = "URL de la console"
  value       = "https://console.aws.amazon.com/cost-management/home#/cost-explorer"
}

output "activation_instructions" {
  description = "Instructions d'activation"
  value       = "Cost Explorer doit être activé manuellement: AWS Console → Billing → Cost Explorer → Enable Cost Explorer"
}
