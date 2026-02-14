# ═══════════════════════════════════════════════════════════════
# CLOUDFRONT - outputs.tf
# ═══════════════════════════════════════════════════════════════

output "distribution_id" {
  description = "ID de la distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "distribution_arn" {
  description = "ARN de la distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "domain_name" {
  description = "Domain name CloudFront"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "hosted_zone_id" {
  description = "Hosted Zone ID"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "status" {
  description = "Statut de la distribution"
  value       = aws_cloudfront_distribution.main.status
}
