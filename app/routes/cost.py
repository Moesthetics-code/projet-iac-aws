"""Routes pour les services de coût (Budgets, Cost Explorer, Trusted Advisor)."""
from flask import Blueprint, render_template, request
import json
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService

cost_bp = Blueprint('cost', __name__)

# ========== BUDGETS ==========
@cost_bp.route('/budgets')
def budgets_form():
    """Formulaire AWS Budgets."""
    return render_template('form_budgets.html')

@cost_bp.route('/trigger-budgets', methods=['POST'])
def trigger_budgets():
    """Déclenche le workflow Budgets."""
    try:
        budget_name = request.form.get("budget_name", "").strip()
        budget_amount = request.form.get("budget_amount", "").strip()
        time_unit = request.form.get("time_unit", "MONTHLY").strip()
        alerts = request.form.get("alerts", "[]")
        
        if not all([budget_name, budget_amount]):
            return ResponseService.error_response("Champs obligatoires manquants", service="BUDGETS")
        
        payload = {
            "ref": "main",
            "inputs": {
                "budget_name": budget_name,
                "budget_amount": budget_amount,
                "time_unit": time_unit,
                "alerts": alerts
            }
        }

        response = GitHubService.trigger_workflow("budgets", payload)
        
        if response.status_code == 204:
            alerts_count = len(json.loads(alerts))
            return ResponseService.success_response(
                service="BUDGETS",
                title="Budget AWS",
                details={
                    "Budget": budget_name,
                    "Montant": f"${budget_amount} USD",
                    "Période": time_unit,
                    "Alertes": f"{alerts_count} seuils"
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API ({response.status_code})",
                response.text,
                service="BUDGETS"
            )
    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="BUDGETS")

# ========== COST EXPLORER ==========
@cost_bp.route('/cost-explorer')
def cost_explorer_form():
    """Formulaire Cost Explorer."""
    return render_template('form_cost_explorer.html')

@cost_bp.route('/trigger-cost-explorer', methods=['POST'])
def trigger_cost_explorer():
    """Déclenche le workflow Terraform Cost Explorer."""
    try:
        report_name = request.form.get("report_name", "cost-report").strip()
        enable_reports = "true" if request.form.get("enable_reports") else "false"
        report_email = request.form.get("report_email", "").strip()

        payload = {
            "ref": "main",
            "inputs": {
                "report_name": report_name,
                "enable_reports": enable_reports,
                "report_email": report_email
            }
        }

        response = GitHubService.trigger_workflow("cost-explorer", payload)
        
        if response.status_code == 204:
            details = {
                "Rapport": report_name,
                "API": "Activée (gratuite)",
            }
            
            if enable_reports == "true":
                details["Rapports email"] = "Activés"

            return ResponseService.success_response(service="COSTEXPLORER", title="Cost Explorer", details=details)
        else:
            return ResponseService.error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="COSTEXPLORER")
    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="COSTEXPLORER")

# ========== TRUSTED ADVISOR ==========
@cost_bp.route('/trusted-advisor')
def trusted_advisor_form():
    """Formulaire Trusted Advisor."""
    return render_template('form_trusted_advisor.html')

@cost_bp.route('/trigger-trusted-advisor', methods=['POST'])
def trigger_trusted_advisor():
    """Déclenche le workflow Terraform Trusted Advisor."""
    try:
        notify_cost = "true" if request.form.get("notify_cost") else "false"
        notify_security = "true" if request.form.get("notify_security") else "false"
        notify_performance = "true" if request.form.get("notify_performance") else "false"
        notify_limits = "true" if request.form.get("notify_limits") else "false"

        payload = {
            "ref": "main",
            "inputs": {
                "notify_cost": notify_cost,
                "notify_security": notify_security,
                "notify_performance": notify_performance,
                "notify_limits": notify_limits
            }
        }

        response = GitHubService.trigger_workflow("trusted-advisor", payload)
        
        if response.status_code == 204:
            notifications = []
            if notify_cost == "true": notifications.append("Coûts")
            if notify_security == "true": notifications.append("Sécurité")
            if notify_performance == "true": notifications.append("Performance")
            if notify_limits == "true": notifications.append("Limites")
            
            details = {
                "Vérifications gratuites": "7 actives",
                "Notifications": ", ".join(notifications) if notifications else "Aucune",
                "Accès complet": "Plan Business requis"
            }

            return ResponseService.success_response(service="TRUSTEDADVISOR", title="Trusted Advisor", details=details)
        else:
            return ResponseService.error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="TRUSTEDADVISOR")
    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="TRUSTEDADVISOR")
