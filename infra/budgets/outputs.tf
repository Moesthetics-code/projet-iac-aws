output "budget_name" {
  description = "Nom du budget"
  value       = aws_budgets_budget.main.name
}

output "budget_id" {
  description = "ID du budget"
  value       = aws_budgets_budget.main.id
}

output "budget_arn" {
  description = "ARN du budget"
  value       = aws_budgets_budget.main.arn
}

output "budget_amount" {
  description = "Montant du budget"
  value       = "${aws_budgets_budget.main.limit_amount} ${aws_budgets_budget.main.limit_unit}"
}

output "console_url" {
  description = "URL de la console"
  value       = "https://console.aws.amazon.com/billing/home#/budgets"
}
