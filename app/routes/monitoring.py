"""Routes pour les services de monitoring (CloudWatch)."""
from flask import Blueprint, render_template, request
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService

monitoring_bp = Blueprint('monitoring', __name__)

@monitoring_bp.route('/cloudwatch')
def cloudwatch_form():
    """Formulaire CloudWatch — Monitoring."""
    return render_template('form_cloudwatch.html')

@monitoring_bp.route('/cloudwatch/trigger', methods=['POST'])
def trigger_cloudwatch():
    """Déclenche le workflow Terraform CloudWatch."""
    try:
        alarm_name = request.form.get("alarm_name", "").strip()
        metric     = request.form.get("metric_name", "").strip()
        threshold  = request.form.get("threshold", "").strip()

        if not all([alarm_name, metric, threshold]):
            return ResponseService.error_response("Champs obligatoires manquants", service="CLOUDWATCH")

        payload = {
            "ref": "main",
            "inputs": {
                "alarm_name":   alarm_name,
                "metric_name":  metric,
                "threshold":    threshold,
            }
        }

        response = GitHubService.trigger_workflow("cloudwatch", payload)
        
        if response.status_code == 204:
            return ResponseService.success_response(
                service="CLOUDWATCH",
                title="Alarme CloudWatch",
                details={
                    "Nom":       alarm_name,
                    "Métrique":  metric,
                    "Seuil":     threshold,
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API ({response.status_code})", 
                response.text, 
                service="CLOUDWATCH"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="CLOUDWATCH")