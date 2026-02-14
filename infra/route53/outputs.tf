# ═══════════════════════════════════════════════════════════════
# ROUTE 53 - outputs.tf
# ═══════════════════════════════════════════════════════════════

output "zone_id" {
  description = "ID de la zone"
  value       = aws_route53_zone.main.zone_id
}

output "zone_arn" {
  description = "ARN de la zone"
  value       = aws_route53_zone.main.arn
}

output "name_servers" {
  description = "Name servers"
  value       = aws_route53_zone.main.name_servers
}

output "record_fqdn" {
  description = "FQDN complet de l'enregistrement"
  value       = var.record_name != "" ? "${var.record_name}.${var.zone_name}" : var.zone_name
}
