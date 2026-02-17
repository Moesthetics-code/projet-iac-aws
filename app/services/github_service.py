"""Service pour interagir avec l'API GitHub."""
import requests
from flask import current_app

class GitHubService:
    """Service GitHub pour déclencher les workflows."""
    
    @staticmethod
    def trigger_workflow(workflow_name, payload):
        """
        Déclenche un workflow GitHub Actions.
        
        Args:
            workflow_name: Nom du workflow (clé dans WORKFLOWS)
            payload: Données à envoyer au workflow
            
        Returns:
            Response object de requests
            
        Raises:
            ValueError: Si le workflow n'existe pas
        """
        
        workflow_file = current_app.config['WORKFLOWS'].get(workflow_name)
        if not workflow_file:
            raise ValueError(f"Workflow '{workflow_name}' non trouvé dans la configuration")
        
        url = (
            f"https://api.github.com/repos/"
            f"{current_app.config['GITHUB_REPO_OWNER']}/"
            f"{current_app.config['GITHUB_REPO_NAME']}/"
            f"actions/workflows/{workflow_file}/dispatches"
        )
        
        headers = {
            'Accept': 'application/vnd.github.v3+json',
            'Authorization': f"token {current_app.config['GITHUB_TOKEN']}"
        }
        
        return requests.post(url, headers=headers, json=payload, timeout=10)