"""Factory Flask pour créer l'application."""
from flask import Flask
from app.config import config

def create_app(config_name='default'):
    """
    Factory pour créer l'application Flask.
    
    Args:
        config_name: Nom de la configuration ('development', 'production', 'testing')
        
    Returns:
        Application Flask configurée avec tous les blueprints
    """
    app = Flask(__name__)
    
    # Charger la configuration
    app.config.from_object(config[config_name])
    
    # Configuration supplémentaire
    app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50 MB max upload
    
    # Enregistrer les blueprints
    from app.routes.main import main_bp
    from app.routes.storage import storage_bp
    from app.routes.compute import compute_bp
    from app.routes.database import database_bp
    from app.routes.network import network_bp
    from app.routes.security import security_bp
    from app.routes.monitoring import monitoring_bp
    from app.routes.devops import devops_bp
    from app.routes.management import management_bp
    from app.routes.cost import cost_bp
    
    # Routes principales (sans préfixe)
    app.register_blueprint(main_bp)
    
    # Routes avec préfixes (correspondant aux URLs originales)
    app.register_blueprint(storage_bp)      # /s3
    app.register_blueprint(compute_bp)      # /ec2, /lambda
    app.register_blueprint(database_bp)     # /rds
    app.register_blueprint(network_bp)      # /vpc, /elb, /cloudfront, /route53
    app.register_blueprint(security_bp)     # /iam, /secrets-manager
    app.register_blueprint(monitoring_bp)   # /cloudwatch
    app.register_blueprint(devops_bp)       # /codepipeline, /codebuild, /codedeploy
    app.register_blueprint(management_bp)   # /ssm
    app.register_blueprint(cost_bp)         # /cost-explorer, /trusted-advisor
    
    return app