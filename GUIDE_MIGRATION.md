# 📘 GUIDE DE MIGRATION - Structure Modulaire Flask

## 🎯 Vue d'Ensemble

Ce guide explique comment migrer votre application Flask monolithique vers une architecture modulaire professionnelle utilisant le **pattern Factory**.

---

## 📁 Structure Avant/Après

### ❌ **AVANT** (Monolithique)
```
projet/
├── app.py                    # 3000+ lignes de code
├── templates/
│   ├── form_s3.html
│   ├── form_lambda.html
│   └── ... (50+ fichiers HTML)
└── infra/
```

**Problèmes** :
- Fichier app.py gigantesque (3000+ lignes)
- Impossible à maintenir
- Difficile d'ajouter de nouveaux services
- Pas de séparation des préoccupations
- Tests impossibles

### ✅ **APRÈS** (Modulaire)
```
projet/
├── app/
│   ├── __init__.py           # Factory (20 lignes)
│   ├── config.py             # Configuration (80 lignes)
│   ├── routes/               # Routes par domaine
│   │   ├── devops.py         # ~150 lignes
│   │   ├── security.py       # ~150 lignes
│   │   └── ...
│   ├── services/             # Logique métier réutilisable
│   │   ├── github_service.py
│   │   └── validation_service.py
│   └── templates/            # Templates organisés
│       ├── devops/
│       ├── security/
│       └── ...
├── run.py                    # Point d'entrée dev
├── wsgi.py                   # Point d'entrée prod
└── .env                      # Configuration
```

**Avantages** :
- ✅ Code organisé (~150 lignes par fichier)
- ✅ Facile à maintenir et comprendre
- ✅ Ajout de services en 5 minutes
- ✅ Tests unitaires simples
- ✅ Déploiement professionnel

---

## 🚀 Migration Étape par Étape

### **ÉTAPE 1 : Backup**

```bash
# Sauvegardez votre projet actuel
cp -r sonatel-iac-project sonatel-iac-project-backup
cd sonatel-iac-project
```

### **ÉTAPE 2 : Créer la nouvelle structure**

```bash
# Créer les dossiers
mkdir -p app/{routes,services,templates,static/{css,js,img},utils}
mkdir -p app/templates/{devops,security,cost,storage,compute,management}

# Créer les fichiers __init__.py
touch app/__init__.py
touch app/routes/__init__.py
touch app/services/__init__.py
touch app/utils/__init__.py
```

### **ÉTAPE 3 : Copier les fichiers modulaires**

Copiez les fichiers fournis :

```bash
# Configuration
cp config.py app/config.py

# Factory
cp app__init__.py app/__init__.py

# Services
cp app_services_*.py app/services/
# Renommer les fichiers
cd app/services
mv app_services_github_service.py github_service.py
mv app_services_response_service.py response_service.py
mv app_services_validation_service.py validation_service.py
cd ../..

# Routes
cp app_routes_*.py app/routes/
cd app/routes
mv app_routes_main.py main.py
mv app_routes_devops.py devops.py
mv app_routes_security.py security.py
cd ../..

# Points d'entrée
cp run.py .
cp wsgi.py .

# Configuration
cp .env.example .env
cp requirements.txt .
```

### **ÉTAPE 4 : Migrer les templates**

```bash
# Déplacer les templates dans les bons dossiers
mv templates/form_codepipeline.html app/templates/devops/
mv templates/form_codebuild.html app/templates/devops/
mv templates/form_codedeploy.html app/templates/devops/

mv templates/form_secrets_manager.html app/templates/security/

mv templates/form_budgets.html app/templates/cost/
mv templates/form_cost_explorer.html app/templates/cost/
mv templates/form_trusted_advisor.html app/templates/cost/

# Créer les templates manquants (success.html, error.html)
```

### **ÉTAPE 5 : Configurer l'environnement**

```bash
# Éditer .env avec vos vraies valeurs
nano .env
```

```env
FLASK_ENV=development
SECRET_KEY=votre-secret-key-aleatoire-securisee

GITHUB_TOKEN=ghp_votre_token_github
GITHUB_REPO_OWNER=votre-organisation
GITHUB_REPO_NAME=sonatel-iac

AWS_REGION=eu-west-3
```

### **ÉTAPE 6 : Installer les dépendances**

```bash
# Créer un environnement virtuel
python3 -m venv venv
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt
```

### **ÉTAPE 7 : Tester**

```bash
# Lancer en mode développement
python run.py

# Ouvrir dans le navigateur
# http://localhost:5000
```

### **ÉTAPE 8 : Compléter les routes manquantes**

Pour chaque service, créez la route dans le bon fichier :

**Exemple : app/routes/cost.py**
```python
from flask import Blueprint, render_template, request
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService

cost_bp = Blueprint('cost', __name__)

@cost_bp.route('/budgets')
def budgets_form():
    return render_template('cost/form_budgets.html')

@cost_bp.route('/budgets/trigger', methods=['POST'])
def trigger_budgets():
    # Logique similaire aux autres routes
    pass
```

---

## 🧪 Tests

Créez `tests/test_routes.py` :

```python
import pytest
from app import create_app

@pytest.fixture
def client():
    app = create_app('testing')
    with app.test_client() as client:
        yield client

def test_index_page(client):
    response = client.get('/')
    assert response.status_code == 200

def test_health_endpoint(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert b'healthy' in response.data
```

Lancer les tests :
```bash
pip install pytest
pytest
```

---

## 🚀 Déploiement Production

### **Option 1 : Gunicorn (recommandé)**

```bash
# Installer Gunicorn
pip install gunicorn

# Lancer l'application
gunicorn -w 4 -b 0.0.0.0:8000 wsgi:app
```

### **Option 2 : Docker**

**Dockerfile**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV FLASK_ENV=production

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "wsgi:app"]
```

**Construire et lancer**
```bash
docker build -t sonatel-iac:latest .
docker run -p 8000:8000 --env-file .env sonatel-iac:latest
```

### **Option 3 : AWS Elastic Beanstalk**

```bash
# Installer EB CLI
pip install awsebcli

# Initialiser
eb init -p python-3.11 sonatel-iac

# Créer environnement
eb create sonatel-iac-prod

# Déployer
eb deploy
```

---

## 📊 Checklist de Migration

- [ ] Backup du projet original
- [ ] Création de la structure de dossiers
- [ ] Copie des fichiers modulaires
- [ ] Migration des templates
- [ ] Configuration .env
- [ ] Installation dépendances
- [ ] Test de l'application (run.py)
- [ ] Migration de toutes les routes
- [ ] Tests unitaires
- [ ] Documentation mise à jour
- [ ] Déploiement production

---

## 🆘 Dépannage

### **Erreur : ModuleNotFoundError: No module named 'app'**

**Solution** : Assurez-vous d'être à la racine du projet et que `app/__init__.py` existe.

### **Erreur : templates not found**

**Solution** : Vérifiez que les templates sont dans `app/templates/` et pas `templates/`.

### **Erreur : GitHub API 401 Unauthorized**

**Solution** : Vérifiez votre `GITHUB_TOKEN` dans `.env`.

---

## 📚 Ressources

- [Flask Factory Pattern](https://flask.palletsprojects.com/en/3.0.x/patterns/appfactories/)
- [Flask Blueprints](https://flask.palletsprojects.com/en/3.0.x/blueprints/)
- [Application Structure Best Practices](https://flask.palletsprojects.com/en/3.0.x/tutorial/layout/)

---

## ✅ Résultat Final

**Avant** : 1 fichier de 3000 lignes  
**Après** : 15 fichiers de ~150 lignes chacun

**Maintenabilité** : 🔴 Impossible → ✅ Facile  
**Testabilité** : 🔴 Impossible → ✅ Simple  
**Scalabilité** : 🔴 Limitée → ✅ Illimitée  

🎉 **Félicitations ! Votre projet est maintenant professionnel et prêt pour la production !**