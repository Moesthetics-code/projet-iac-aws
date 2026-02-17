"""Routes pour les services de stockage (S3)."""
from flask import Blueprint, render_template, request
import re
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService

storage_bp = Blueprint('storage', __name__)

@storage_bp.route('/s3')
def s3_form():
    """Formulaire S3 — Simple Storage Service."""
    return render_template('form_s3.html')

@storage_bp.route('/s3/trigger', methods=['POST'])
def trigger_s3():
    """Déclenche le workflow Terraform S3."""
    try:
        bucket_name    = request.form.get("bucket_name", "").strip().lower()
        bucket_env     = request.form.get("bucket_env", "").strip()
        bucket_region  = request.form.get("bucket_region", "eu-west-3").strip()
        index_document = request.form.get("index_document", "index.html").strip()
        error_document = request.form.get("error_document", "error.html").strip()
        storage_class  = request.form.get("storage_class", "STANDARD").strip()
        enable_versioning = request.form.get("enable_versioning", "Disabled").strip()

        # Toggles
        block_public_acls       = "true" if request.form.get("block_public_acls") else "false"
        block_public_policy     = "true" if request.form.get("block_public_policy") else "false"
        ignore_public_acls      = "true" if request.form.get("ignore_public_acls") else "false"
        restrict_public_buckets = "true" if request.form.get("restrict_public_buckets") else "false"

        # Validations
        if not bucket_name or not bucket_env:
            return ResponseService.error_response("Champs obligatoires manquants", service="S3")

        if not re.match(r'^[a-z0-9][a-z0-9\-]{1,61}[a-z0-9]$', bucket_name):
            return ResponseService.error_response(f"Nom de bucket invalide: '{bucket_name}'", service="S3")

        if '--' in bucket_name:
            return ResponseService.error_response("Le nom du bucket ne peut pas contenir deux tirets consécutifs", service="S3")

        # Payload
        payload = {
            "ref": "main",
            "inputs": {
                "bucket_name":              bucket_name,
                "bucket_env":               bucket_env,
                "bucket_region":            bucket_region,
                "index_document":           index_document,
                "error_document":           error_document,
                "storage_class":            storage_class,
                "enable_versioning":        enable_versioning,
                "block_public_acls":        block_public_acls,
                "block_public_policy":      block_public_policy,
                "ignore_public_acls":       ignore_public_acls,
                "restrict_public_buckets":  restrict_public_buckets,
            }
        }

        response = GitHubService.trigger_workflow("s3", payload)
        
        if response.status_code == 204:
            website_url = f"https://{bucket_name}.s3-website.{bucket_region}.amazonaws.com"
            return ResponseService.success_response(
                service="S3",
                title="Bucket S3",
                details={
                    "Nom":     bucket_name,
                    "Région":  bucket_region,
                    "Env":     bucket_env,
                    "Storage": storage_class,
                    "URL":     website_url,
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API (Code: {response.status_code})",
                response.text,
                service="S3"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="S3")