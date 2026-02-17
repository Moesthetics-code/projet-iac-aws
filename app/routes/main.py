"""Routes principales de l'application."""
from flask import Blueprint, render_template, current_app

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    services = current_app.config['SERVICES']
    return render_template(
        'index.html',
        services=services,
        total=len(services)
    )


@main_bp.route('/aide')
def aide():
    """Page d'aide et guide d'utilisation."""
    return render_template('aide.html')

@main_bp.route('/health')
def health():
    return {"status": "ok", "services": len(current_app.config['SERVICES'])}