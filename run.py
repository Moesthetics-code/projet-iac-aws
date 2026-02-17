"""Point d'entrée pour le développement."""
import os
from app import create_app

# Créer l'application en mode développement
app = create_app(os.getenv('FLASK_ENV', 'development'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)