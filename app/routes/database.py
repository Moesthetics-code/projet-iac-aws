"""Routes pour les services de base de données (RDS)."""
from flask import Blueprint, render_template, request
import re
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService

database_bp = Blueprint('database', __name__)

@database_bp.route('/rds')
def rds_form():
    """Formulaire RDS — Relational Database Service."""
    return render_template('form_rds.html')

@database_bp.route('/rds/trigger', methods=['POST'])
def trigger_rds():
    """Déclenche le workflow Terraform RDS."""
    try:
        db_identifier      = request.form.get("db_identifier", "").strip()
        engine             = request.form.get("engine", "").strip()
        engine_version     = request.form.get("engine_version", "").strip()
        instance_class     = request.form.get("instance_class", "").strip()
        allocated_storage  = request.form.get("allocated_storage", "20").strip()
        db_name            = request.form.get("db_name", "").strip()
        username           = request.form.get("username", "").strip()
        password           = request.form.get("password", "").strip()
        environment        = request.form.get("environment", "").strip()
        multi_az           = "true" if request.form.get("multi_az") else "false"
        backup_retention   = request.form.get("backup_retention", "7").strip()

        # Validations
        if not all([db_identifier, engine, engine_version, instance_class, username, password, environment]):
            return ResponseService.error_response("Champs obligatoires manquants", service="RDS")

        if not re.match(r'^[a-z][a-z0-9\-]*$', db_identifier):
            return ResponseService.error_response(f"DB Identifier invalide: '{db_identifier}'", service="RDS")

        if len(username) < 3 or len(username) > 16:
            return ResponseService.error_response("Username doit contenir entre 3 et 16 caractères", service="RDS")

        if len(password) < 8:
            return ResponseService.error_response("Le mot de passe doit contenir au moins 8 caractères", service="RDS")

        # Payload
        payload = {
            "ref": "main",
            "inputs": {
                "db_identifier":     db_identifier,
                "engine":            engine,
                "engine_version":    engine_version,
                "instance_class":    instance_class,
                "allocated_storage": allocated_storage,
                "db_name":           db_name,
                "username":          username,
                "password":          password,
                "environment":       environment,
                "multi_az":          multi_az,
                "backup_retention":  backup_retention,
            }
        }

        response = GitHubService.trigger_workflow("rds", payload)
        
        if response.status_code == 204:
            return ResponseService.success_response(
                service="RDS",
                title="Base de données RDS",
                details={
                    "Identifier":  db_identifier,
                    "Engine":      f"{engine} {engine_version}",
                    "Class":       instance_class,
                    "Storage":     f"{allocated_storage} GB",
                    "Multi-AZ":    "Oui" if multi_az == "true" else "Non",
                    "Env":         environment,
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API (Code: {response.status_code})",
                response.text,
                service="RDS"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="RDS")