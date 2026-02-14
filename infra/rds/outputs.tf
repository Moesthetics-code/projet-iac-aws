# ═══════════════════════════════════════════════════════════════
# RDS - outputs.tf
# ═══════════════════════════════════════════════════════════════

output "db_instance_id" {
  description = "ID de l'instance RDS"
  value       = aws_db_instance.main.id
}

output "db_endpoint" {
  description = "Endpoint de connexion"
  value       = aws_db_instance.main.endpoint
}

output "db_arn" {
  description = "ARN de l'instance RDS"
  value       = aws_db_instance.main.arn
}

output "db_name" {
  description = "Nom de la base de données"
  value       = aws_db_instance.main.db_name
}

output "db_port" {
  description = "Port de la base de données"
  value       = aws_db_instance.main.port
}

output "db_address" {
  description = "Adresse de la base de données"
  value       = aws_db_instance.main.address
}

output "connection_string" {
  description = "Chaîne de connexion (password masqué)"
  value       = "${var.engine}://${var.username}:***@${aws_db_instance.main.endpoint}/${var.db_name}"
  sensitive   = true
}

output "security_group_id" {
  description = "ID du Security Group"
  value       = aws_security_group.rds.id
}

output "subnet_group_name" {
  description = "Nom du DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}
