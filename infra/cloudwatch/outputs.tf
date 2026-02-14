# ═══════════════════════════════════════════════════════════════
# CLOUDWATCH - outputs.tf
# ═══════════════════════════════════════════════════════════════

output "alarm_arn" {
  description = "ARN de l'alarme"
  value       = aws_cloudwatch_metric_alarm.main.arn
}

output "alarm_name" {
  description = "Nom de l'alarme"
  value       = aws_cloudwatch_metric_alarm.main.alarm_name
}

output "log_group_name" {
  description = "Nom du log group"
  value       = aws_cloudwatch_log_group.main.name
}
