# ─────────────────────────────────────────────────────────────────────────────
#  main.tf — PROJET IAC SONATEL · S3 Static Website Deployer
#  Ressources créées:
#    1. aws_s3_bucket                      — Le bucket principal
#    2. aws_s3_bucket_public_access_block  — Désactive les protections publiques
#    3. aws_s3_bucket_website_configuration— Configure l'hébergement web statique
#    4. aws_s3_bucket_policy               — Policy GetObject pour l'accès public
#    5. aws_s3_bucket_versioning           — Versioning (optionnel)
#    6. aws_s3_bucket_cors_configuration   — CORS pour les requêtes cross-origin
#    7. aws_s3_object (fileset)            — Upload des fichiers du site
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ─────────────────────────────────────────────────────────────────────────────
#  1. BUCKET PRINCIPAL
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  # Empêche la destruction accidentelle en production
  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    Name        = var.bucket_name
    Environment = var.bucket_env
    ManagedBy   = "Terraform"
    Project     = "Sonatel-IAC"
    Purpose     = "StaticWebsite"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
#  2. CONTRÔLE D'ACCÈS PUBLIC
#  IMPORTANT: Les 4 options DOIVENT être false pour servir un site web
#  statique accessible publiquement via GetObject.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = var.block_public_acls       # false
  block_public_policy     = var.block_public_policy     # false
  ignore_public_acls      = var.ignore_public_acls      # false
  restrict_public_buckets = var.restrict_public_buckets # false

  # Ce bloc DOIT être créé AVANT la bucket policy (dépendance explicite)
  depends_on = [aws_s3_bucket.static_site]
}

# ─────────────────────────────────────────────────────────────────────────────
#  3. CONFIGURATION SITE WEB STATIQUE
#  Permet à S3 de servir les fichiers comme un serveur HTTP basique.
#  AWS génère l'endpoint: <bucket>.s3-website.<region>.amazonaws.com
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }

  depends_on = [aws_s3_bucket_public_access_block.static_site]
}

# ─────────────────────────────────────────────────────────────────────────────
#  4. BUCKET POLICY — GetObject public
#  Autorise n'importe qui à lire les objets (s3:GetObject sur *).
#  Nécessaire pour que les visiteurs accèdent au site.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })

  # La policy ne peut être attachée qu'APRÈS avoir désactivé le block public access
  depends_on = [aws_s3_bucket_public_access_block.static_site]
}

# ─────────────────────────────────────────────────────────────────────────────
#  5. VERSIONING
#  Permet de conserver l'historique des objets (utile en prod).
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_s3_bucket_versioning" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  versioning_configuration {
    status = var.enable_versioning  # "Enabled" | "Suspended" | "Disabled"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
#  6. CONFIGURATION CORS
#  Permet les requêtes cross-origin (APIs, fonts, scripts externes).
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_s3_bucket_cors_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "Content-Length", "Content-Type"]
    max_age_seconds = 3600
  }
}

# ─────────────────────────────────────────────────────────────────────────────
#  7. UPLOAD DES FICHIERS DU SITE
#  Terraform scanne le dossier source et crée un aws_s3_object par fichier.
#  Le content_type est déterminé automatiquement via la fonction lookup.
# ─────────────────────────────────────────────────────────────────────────────
locals {
  # Map des extensions vers les MIME types pour les Content-Type HTTP
  mime_types = {
    "html"  = "text/html; charset=utf-8"
    "htm"   = "text/html; charset=utf-8"
    "css"   = "text/css"
    "js"    = "application/javascript"
    "json"  = "application/json"
    "png"   = "image/png"
    "jpg"   = "image/jpeg"
    "jpeg"  = "image/jpeg"
    "gif"   = "image/gif"
    "svg"   = "image/svg+xml"
    "ico"   = "image/x-icon"
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
    "ttf"   = "font/ttf"
    "eot"   = "application/vnd.ms-fontobject"
    "pdf"   = "application/pdf"
    "txt"   = "text/plain"
    "xml"   = "application/xml"
    "webp"  = "image/webp"
    "mp4"   = "video/mp4"
    "webm"  = "video/webm"
  }

  # Récupérer tous les fichiers dans le répertoire source
  site_files = fileset(var.site_source_dir, "**/*")
}

resource "aws_s3_object" "site_files" {
  for_each = local.site_files

  bucket = aws_s3_bucket.static_site.id
  key    = each.value
  source = "${var.site_source_dir}/${each.value}"

  # Content-Type automatique basé sur l'extension
  content_type = lookup(
    local.mime_types,
    reverse(split(".", each.value))[0],
    "application/octet-stream"
  )

  # Classe de stockage pour les objets
  storage_class = var.storage_class

  # ETag pour la détection des changements
  etag = filemd5("${var.site_source_dir}/${each.value}")

  # Cache-Control: 1 heure pour HTML, 1 an pour les assets statiques
  cache_control = endswith(each.value, ".html") ? "max-age=3600" : "max-age=31536000, immutable"

  tags = {
    Environment = var.bucket_env
    ManagedBy   = "Terraform"
    Project     = "Sonatel-IAC"
  }

  depends_on = [
    aws_s3_bucket_policy.public_read,
    aws_s3_bucket_website_configuration.static_site
  ]
}
