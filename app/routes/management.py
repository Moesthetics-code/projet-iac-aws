"""Routes pour les services de gestion (Systems Manager)."""
from flask import Blueprint, render_template, request
import json
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService

management_bp = Blueprint('management', __name__)

@management_bp.route('/ssm')
def ssm_form():
    """Formulaire Systems Manager."""
    return render_template('form_ssm.html')

@management_bp.route('/trigger-ssm', methods=['POST'])
def trigger_ssm():
    """Déclenche le workflow Terraform SSM."""
    try:
        environment = request.form.get("environment", "").strip()
        region = request.form.get("region", "eu-west-3").strip()
        namespace = request.form.get("namespace", "").strip()
        parameters = request.form.get("parameters", "[]")
        
        use_kms = "true" if request.form.get("use_kms") else "false"
        kms_key_id = request.form.get("kms_key_id", "").strip()
        
        enable_session_manager = "true" if request.form.get("enable_session_manager") else "false"
        session_logging = request.form.get("session_logging", "disabled").strip()
        s3_bucket_logs = request.form.get("s3_bucket_logs", "").strip()
        
        if not all([environment, namespace]):
            return ResponseService.error_response("Champs obligatoires manquants", service="SSM")

        if not namespace.startswith('/'):
            return ResponseService.error_response("Le namespace doit commencer par /", service="SSM")

        payload = {
            "ref": "main",
            "inputs": {
                "environment": environment,
                "region": region,
                "namespace": namespace,
                "parameters": parameters,
                "kms_key_id": kms_key_id,
                "enable_session_manager": enable_session_manager,
                "session_logging": session_logging,
                "s3_bucket_logs": s3_bucket_logs
            }
        }

        response = GitHubService.trigger_workflow("ssm", payload)
        
        if response.status_code == 204:
            params_count = len(json.loads(parameters))
            
            details = {
                "Namespace": namespace,
                "Environnement": environment,
                "Paramètres": f"{params_count} créés",
            }
            
            if enable_session_manager == "true":
                details["Session Manager"] = "Activé"
            if use_kms == "true":
                details["Chiffrement"] = "KMS"

            return ResponseService.success_response(service="SSM", title="Parameter Store", details=details)
        else:
            return ResponseService.error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="SSM")
    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="SSM")