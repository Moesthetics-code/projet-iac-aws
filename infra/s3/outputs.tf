# ─────────────────────────────────────────────────────────────────────────────
#  outputs.tf — PROJET IAC SONATEL · S3 Static Website Deployer
# ─────────────────────────────────────────────────────────────────────────────

output "bucket_id" {
  description = "Identifiant (nom) du bucket S3 créé"
  value       = aws_s3_bucket.static_site.id
}

output "bucket_arn" {
  description = "ARN du bucket S3 (Amazon Resource Name)"
  value       = aws_s3_bucket.static_site.arn
}

output "bucket_region" {
  description = "Région AWS du bucket"
  value       = aws_s3_bucket.static_site.region
}

output "bucket_domain_name" {
  description = "Nom de domaine S3 standard du bucket"
  value       = aws_s3_bucket.static_site.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Nom de domaine S3 régional (pour CloudFront)"
  value       = aws_s3_bucket.static_site.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "URL publique du site web statique (endpoint HTTP S3)"
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}

output "website_domain" {
  description = "Domaine du site web statique (sans https://)"
  value       = aws_s3_bucket_website_configuration.static_site.website_domain
}

output "website_url" {
  description = "URL complète du site web statique (avec http://)"
  value       = "http://${aws_s3_bucket_website_configuration.static_site.website_endpoint}"
}

output "files_uploaded" {
  description = "Nombre de fichiers uploadés dans le bucket"
  value       = length(aws_s3_object.site_files)
}

output "index_document" {
  description = "Document index configuré"
  value       = var.index_document
}

output "error_document" {
  description = "Document d'erreur 404 configuré"
  value       = var.error_document
}

output "versioning_status" {
  description = "État du versioning du bucket"
  value       = aws_s3_bucket_versioning.static_site.versioning_configuration[0].status
}

output "curl_command" {
  description = "Commande curl pour tester l'accès public au site"
  value       = "curl -I http://${aws_s3_bucket_website_configuration.static_site.website_endpoint}"
}

output "public_access_block" {
  description = "Configuration du bloc d'accès public (les 4 doivent être false pour un site public)"
  value = {
    block_public_acls       = var.block_public_acls
    block_public_policy     = var.block_public_policy
    ignore_public_acls      = var.ignore_public_acls
    restrict_public_buckets = var.restrict_public_buckets
  }
}
