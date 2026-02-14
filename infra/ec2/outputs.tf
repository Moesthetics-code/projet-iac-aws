# ═══════════════════════════════════════════════════════════════
# TERRAFORM EC2 - Outputs
# ═══════════════════════════════════════════════════════════════

output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.main.id
}

output "instance_arn" {
  description = "ARN de l'instance EC2"
  value       = aws_instance.main.arn
}

output "public_ip" {
  description = "Adresse IP publique de l'instance"
  value       = aws_instance.main.public_ip
}

output "private_ip" {
  description = "Adresse IP privée de l'instance"
  value       = aws_instance.main.private_ip
}

output "public_dns" {
  description = "DNS public de l'instance"
  value       = aws_instance.main.public_dns
}

output "security_group_id" {
  description = "ID du Security Group"
  value       = aws_security_group.ec2_sg.id
}

output "ssh_command" {
  description = "Commande SSH pour se connecter"
  value       = "ssh -i YOUR_KEY.pem ec2-user@${aws_instance.main.public_ip}"
}

output "http_url" {
  description = "URL HTTP de l'instance"
  value       = "http://${aws_instance.main.public_ip}"
}