# ═══════════════════════════════════════════════════════════════
# ELB - outputs.tf
# ═══════════════════════════════════════════════════════════════

output "lb_arn" {
  description = "ARN du Load Balancer"
  value       = aws_lb.main.arn
}

output "lb_dns_name" {
  description = "DNS du Load Balancer"
  value       = aws_lb.main.dns_name
}

output "lb_zone_id" {
  description = "Zone ID du Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN du Target Group"
  value       = aws_lb_target_group.main.arn
}
