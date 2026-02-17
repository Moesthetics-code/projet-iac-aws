"""Service pour validations communes."""
import re

class ValidationService:
    """Service de validation."""
    
    @staticmethod
    def validate_bucket_name(name):
        """
        Valide un nom de bucket S3.
        
        Returns:
            (bool, str): (is_valid, error_message)
        """
        if not re.match(r'^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$', name):
            return False, "Nom invalide (3-63 caractères, minuscules, chiffres, tirets)"
        if '..' in name or '.-' in name or '-.' in name:
            return False, "Nom invalide (pas de points ou tirets consécutifs)"
        return True, ""
    
    @staticmethod
    def validate_secret_name(name):
        """Valide un nom de secret Secrets Manager."""
        if not re.match(r'^[a-zA-Z0-9/_+=.@-]+$', name):
            return False, "Caractères invalides dans le nom"
        if len(name) > 512:
            return False, "Nom trop long (max 512 caractères)"
        return True, ""
    
    @staticmethod
    def validate_pipeline_name(name):
        """Valide un nom de pipeline CodePipeline."""
        if not re.match(r'^[A-Za-z0-9.@\-_]+$', name):
            return False, "Nom invalide (utilisez: A-Z a-z 0-9 . @ - _)"
        if len(name) > 100:
            return False, "Nom trop long (max 100 caractères)"
        return True, ""
    
    @staticmethod
    def validate_required_fields(data, required_fields):
        """
        Valide que tous les champs requis sont présents.
        
        Args:
            data: Dictionnaire de données (ex: request.form)
            required_fields: Liste des champs requis
            
        Returns:
            (bool, str): (is_valid, error_message)
        """
        missing = [f for f in required_fields if not data.get(f, '').strip()]
        if missing:
            return False, f"Champs manquants: {', '.join(missing)}"
        return True, ""