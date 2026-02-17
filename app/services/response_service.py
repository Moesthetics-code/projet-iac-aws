"""Service pour générer les réponses standardisées."""
from flask import render_template, current_app


class ResponseService:
    """Service pour réponses standardisées."""

    @staticmethod
    def success_response(service: str, title: str, details: dict):
        """
        Génère une page HTML de succès.

        Args:
            service: Nom du service AWS (ex: 'S3', 'LAMBDA')
            title:   Titre affiché sur la page
            details: Dictionnaire clé/valeur des informations de déploiement

        Returns:
            Réponse HTML 200
        """
        color        = current_app.config['SERVICE_COLORS'].get(service.upper(), '#3b82f6')
        github_owner = current_app.config.get('GITHUB_REPO_OWNER', '')
        github_repo  = current_app.config.get('GITHUB_REPO_NAME', '')

        return render_template(
            'success.html',
            service=service,
            color=color,
            title=title,
            details=details,
            github_owner=github_owner,
            github_repo=github_repo,
        )

    @staticmethod
    def error_response(message: str, details: str = "", service: str = ""):
        """
        Génère une page HTML d'erreur.

        Args:
            message: Message d'erreur principal
            details: Détails techniques (réponse API, traceback…)
            service: Nom du service AWS

        Returns:
            Réponse HTML 400
        """
        color = current_app.config['SERVICE_COLORS'].get(service.upper(), '#ef4444')

        return render_template(
            'error.html',
            message=message,
            details=details,
            service=service,
            color=color,
        ), 400