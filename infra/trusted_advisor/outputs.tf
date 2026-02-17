output "sns_topic_arn" {
  description = "ARN du topic SNS"
  value       = aws_sns_topic.trusted_advisor.arn
}

output "policy_arn" {
  description = "ARN de la policy IAM"
  value       = aws_iam_policy.ta_access.arn
}

output "console_url" {
  description = "URL de la console"
  value       = "https://console.aws.amazon.com/trustedadvisor/"
}

output "activation_note" {
  description = "Note importante"
  value       = "⚠️ Les 7 vérifications de base sont gratuites. Pour les 115+ vérifications complètes, un plan Business ($100/mois) ou Enterprise est requis."
}
