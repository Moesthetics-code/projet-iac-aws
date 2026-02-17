"""Point d'entrée WSGI pour la production."""
import os
from app import create_app

app = create_app(os.getenv('FLASK_ENV', 'production'))

if __name__ == "__main__":
    app.run()