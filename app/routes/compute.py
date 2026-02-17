"""Routes pour les services de calcul (EC2, Lambda)."""
from flask import Blueprint, render_template, request
import re
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService

compute_bp = Blueprint('compute', __name__)

# ========== EC2 ==========
@compute_bp.route('/ec2')
def ec2_form():
    """Formulaire EC2 — Elastic Compute Cloud."""
    return render_template('form_ec2.html')

@compute_bp.route('/ec2/trigger', methods=['POST'])
def trigger_ec2():
    """Déclenche le workflow Terraform EC2."""
    try:
        # Récupération des champs
        instance_name = request.form.get("instance_name", "").strip()
        instance_os   = request.form.get("instance_os", "").strip()
        instance_size = request.form.get("instance_size", "").strip()
        instance_env  = request.form.get("instance_env", "").strip()

        # Validations
        if not all([instance_name, instance_os, instance_size, instance_env]):
            return ResponseService.error_response("Tous les champs sont obligatoires", service="EC2")

        if not re.match(r'^[a-zA-Z0-9_-]+$', instance_name):
            return ResponseService.error_response(f"Nom invalide: '{instance_name}'", service="EC2")

        if not instance_os.startswith("ami-"):
            return ResponseService.error_response(f"AMI invalide: '{instance_os}'", service="EC2")

        if instance_env not in ["dev", "preprod", "prod"]:
            return ResponseService.error_response(f"Environnement invalide: '{instance_env}'", service="EC2")

        # Payload GitHub Actions
        payload = {
            "ref": "main",
            "inputs": {
                "instance_name": instance_name,
                "instance_os":   instance_os,
                "instance_size": instance_size,
                "instance_env":  instance_env,
            }
        }

        # Déclenchement du workflow
        response = GitHubService.trigger_workflow("ec2", payload)
        
        if response.status_code == 204:
            return ResponseService.success_response(
                service="EC2",
                title="Instance EC2",
                details={
                    "Nom":          instance_name,
                    "AMI":          instance_os,
                    "Type":         instance_size,
                    "Environnement": instance_env,
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API (Code: {response.status_code})",
                response.text,
                service="EC2"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="EC2")

# ========== LAMBDA ==========
@compute_bp.route('/lambda')
def lambda_form():
    """Formulaire Lambda — Fonctions serverless."""
    return render_template('form_lambda.html')

@compute_bp.route('/lambda/trigger', methods=['POST'])
def trigger_lambda():
    """Déclenche le workflow Terraform Lambda."""
    try:
        function_name = request.form.get("function_name", "").strip()
        runtime       = request.form.get("runtime", "").strip()
        handler       = request.form.get("handler", "").strip()
        memory_size   = request.form.get("memory_size", "128").strip()
        timeout       = request.form.get("timeout", "3").strip()
        environment   = request.form.get("environment", "").strip()

        if not all([function_name, runtime, handler, environment]):
            return ResponseService.error_response("Champs obligatoires manquants", service="LAMBDA")

        payload = {
            "ref": "main",
            "inputs": {
                "function_name": function_name,
                "runtime":       runtime,
                "handler":       handler,
                "memory_size":   memory_size,
                "timeout":       timeout,
                "environment":   environment,
            }
        }

        response = GitHubService.trigger_workflow("lambda", payload)
        
        if response.status_code == 204:
            return ResponseService.success_response(
                service="LAMBDA",
                title="Fonction Lambda",
                details={
                    "Nom":     function_name,
                    "Runtime": runtime,
                    "Memory":  f"{memory_size} MB",
                    "Timeout": f"{timeout}s",
                    "Env":     environment,
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API ({response.status_code})", 
                response.text, 
                service="LAMBDA"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="LAMBDA")