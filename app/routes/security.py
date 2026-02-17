"""Routes pour les services de sécurité (IAM, Secrets Manager)."""
from flask import Blueprint, render_template, request
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService
from app.services.validation_service import ValidationService

security_bp = Blueprint('security', __name__)

# ========== IAM ==========
@security_bp.route('/iam')
def iam_form():
    """Formulaire IAM — Identity and Access Management."""
    return render_template('form_iam.html')

@security_bp.route('/iam/trigger', methods=['POST'])
def trigger_iam():
    """Déclenche le workflow Terraform IAM."""
    try:
        resource_type = request.form.get("resource_type", "").strip()
        resource_name = request.form.get("resource_name", "").strip()
        path          = request.form.get("path", "/").strip()

        if not all([resource_type, resource_name]):
            return ResponseService.error_response("Champs obligatoires manquants", service="IAM")

        payload = {
            "ref": "main",
            "inputs": {
                "resource_type": resource_type,
                "resource_name": resource_name,
                "path":          path,
            }
        }

        response = GitHubService.trigger_workflow("iam", payload)
        
        if response.status_code == 204:
            return ResponseService.success_response(
                service="IAM",
                title="Ressource IAM",
                details={
                    "Type": resource_type,
                    "Nom":  resource_name,
                    "Path": path,
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API ({response.status_code})", 
                response.text, 
                service="IAM"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="IAM")

# ========== SECRETS MANAGER ==========
@security_bp.route('/secrets-manager')
def secrets_manager_form():
    """Formulaire Secrets Manager."""
    return render_template('form_secrets_manager.html')

@security_bp.route('/secrets-manager/trigger', methods=['POST'])
def trigger_secrets_manager():
    """Déclenche le workflow Secrets Manager."""
    try:
        secret_name = request.form.get('secret_name', '').strip()
        secret_type = request.form.get('secret_type', '').strip()
        
        # Validation
        is_valid, error_msg = ValidationService.validate_secret_name(secret_name)
        if not is_valid:
            return ResponseService.error_response(error_msg, service='SECRETSMANAGER')
        
        required = ['secret_name', 'environment', 'secret_type']
        is_valid, error_msg = ValidationService.validate_required_fields(
            request.form, required
        )
        if not is_valid:
            return ResponseService.error_response(error_msg, service='SECRETSMANAGER')
        
        # Validation selon le type
        if secret_type == 'database':
            db_required = ['db_username', 'db_password']
            for field in db_required:
                if not request.form.get(field, '').strip():
                    return ResponseService.error_response(
                        f"Champ {field} obligatoire pour type database",
                        service='SECRETSMANAGER'
                    )
        else:
            if not request.form.get('secret_value', '').strip():
                return ResponseService.error_response(
                    "La valeur du secret est obligatoire",
                    service='SECRETSMANAGER'
                )
        
        # Payload
        payload = {
            'ref': 'main',
            'inputs': {
                'secret_name': secret_name,
                'environment': request.form.get('environment'),
                'region': request.form.get('region', 'eu-west-3'),
                'description': request.form.get('description', ''),
                'secret_type': secret_type,
                'db_username': request.form.get('db_username', ''),
                'db_password': request.form.get('db_password', ''),
                'db_host': request.form.get('db_host', ''),
                'db_port': request.form.get('db_port', '5432'),
                'db_name': request.form.get('db_name', ''),
                'secret_value': request.form.get('secret_value', ''),
                'enable_rotation': 'true' if request.form.get('enable_rotation') else 'false',
                'rotation_days': request.form.get('rotation_days', '30'),
                'rotation_lambda_arn': request.form.get('rotation_lambda', ''),
                'kms_key_id': request.form.get('kms_key_id', ''),
                'recovery_window_enabled': 'true' if request.form.get('recovery_window') else 'false',
                'enable_replication': 'true' if request.form.get('enable_replication') else 'false',
                'replica_regions': request.form.get('replica_regions', ''),
            }
        }
        
        response = GitHubService.trigger_workflow('secrets-manager', payload)
        
        if response.status_code == 204:
            details = {
                'Nom': secret_name,
                'Type': secret_type.replace('_', ' ').title(),
                'Environnement': request.form.get('environment')
            }
            
            if request.form.get('enable_rotation'):
                details['Rotation'] = f"Tous les {request.form.get('rotation_days', '30')} jours"
            
            return ResponseService.success_response(
                service='SECRETSMANAGER',
                title='Secret Sécurisé',
                details=details
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API ({response.status_code})",
                response.text,
                service='SECRETSMANAGER'
            )
            
    except Exception as e:
        return ResponseService.error_response(
            "Erreur inattendue",
            str(e),
            service='SECRETSMANAGER'
        )