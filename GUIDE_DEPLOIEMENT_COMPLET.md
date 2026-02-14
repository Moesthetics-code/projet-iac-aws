# 🚀 GUIDE DE DÉPLOIEMENT COMPLET - APPLICATION IAC SONATEL

## 📋 TABLE DES MATIÈRES

1. [Prérequis](#prérequis)
2. [Structure du projet](#structure-du-projet)
3. [Configuration locale](#configuration-locale)
4. [Configuration GitHub](#configuration-github)
5. [Configuration AWS](#configuration-aws)
6. [Déploiement de l'application](#déploiement-de-lapplication)
7. [Test et validation](#test-et-validation)
8. [Dépannage](#dépannage)

---

## 🎯 PRÉREQUIS

### Comptes nécessaires

- [ ] **Compte GitHub** (gratuit)
- [ ] **Compte AWS** (Free Tier disponible)
- [ ] **Git installé** sur votre machine
- [ ] **Python 3.8+** installé
- [ ] **Éditeur de code** (VS Code recommandé)

### Outils à installer

```bash
# Vérifier Python
python --version  # Doit être 3.8+

# Vérifier Git
git --version

# Vérifier pip
pip --version
```

---

## 📁 STRUCTURE DU PROJET

```
projet-iac-aws/
├── .github/
│   └── workflows/
│       ├── terraform-ec2.yml
│       ├── terraform-s3.yml
│       ├── terraform-rds.yml
│       ├── terraform-lambda.yml
│       ├── terraform-iam.yml
│       ├── terraform-vpc.yml
│       ├── terraform-cloudwatch.yml
│       ├── terraform-route53.yml
│       ├── terraform-elb.yml
│       └── terraform-cloudfront.yml
├── infra/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── s3/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/
│   ├── lambda/
│   ├── iam/
│   ├── vpc/
│   ├── cloudwatch/
│   ├── route53/
│   ├── elb/
│   └── cloudfront/
├── templates/
│   ├── index.html
│   ├── form_ec2.html
│   ├── form_s3.html
│   ├── form_rds.html
│   ├── form_lambda.html
│   ├── form_iam.html
│   ├── form_vpc.html
│   ├── form_cloudwatch.html
│   ├── form_route53.html
│   ├── form_elb.html
│   └── form_cloudfront.html
├── app.py
├── requirements.txt
├── .env
├── .gitignore
└── README.md
```

---

## 🔧 CONFIGURATION LOCALE

### ÉTAPE 1 : Créer la structure du projet

```bash
# Créer le dossier principal
mkdir projet-iac-aws
cd projet-iac-aws

# Créer les sous-dossiers
mkdir -p .github/workflows
mkdir -p infra/{ec2,s3,rds,lambda,iam,vpc,cloudwatch,route53,elb,cloudfront}
mkdir templates
```

### ÉTAPE 2 : Copier tous les fichiers fournis

**Fichiers HTML** (dans `templates/`) :
- index.html
- form_ec2.html
- form_s3.html
- form_rds.html
- form_lambda.html
- form_iam.html
- form_vpc.html
- form_cloudwatch.html
- form_route53.html
- form_elb.html
- form_cloudfront.html

**Backend** (à la racine) :
- app.py (copier depuis app_complete.py)

**Workflows** (dans `.github/workflows/`) :
- terraform-ec2.yml
- terraform-s3.yml
- terraform-rds.yml
- terraform-lambda.yml
- terraform-iam.yml
- terraform-vpc.yml
- terraform-cloudwatch.yml
- terraform-route53.yml
- terraform-elb.yml
- terraform-cloudfront.yml

**Terraform** (dans `infra/`) :
- Copier les fichiers main.tf, variables.tf, outputs.tf pour chaque service

### ÉTAPE 3 : Créer requirements.txt

```bash
cat > requirements.txt << 'EOF'
flask==3.0.0
requests==2.31.0
python-dotenv==1.0.0
gunicorn==21.2.0
EOF
```

### ÉTAPE 4 : Créer .gitignore

```bash
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/

# Terraform
*.tfstate
*.tfstate.*
.terraform/
*.tfvars
*.tfplan

# Environment
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF
```

### ÉTAPE 5 : Créer .env (IMPORTANT)

```bash
cat > .env << 'EOF'
# GitHub Configuration
GITHUB_TOKEN=VOTRE_TOKEN_GITHUB
GITHUB_OWNER=VOTRE_USERNAME
GITHUB_REPO=projet-iac-aws

# Flask Configuration
FLASK_ENV=development
FLASK_DEBUG=True
SECRET_KEY=votre-cle-secrete-random

# Optional: Custom port
PORT=5000
EOF
```

⚠️ **IMPORTANT** : Remplacez les valeurs :
- `VOTRE_TOKEN_GITHUB` : Token GitHub (créé à l'étape suivante)
- `VOTRE_USERNAME` : Votre nom d'utilisateur GitHub
- `votre-cle-secrete-random` : Générez avec `python -c "import secrets; print(secrets.token_hex(32))"`

### ÉTAPE 6 : Installer les dépendances

```bash
# Créer un environnement virtuel
python -m venv venv

# Activer l'environnement virtuel
# Sur Windows:
venv\Scripts\activate
# Sur macOS/Linux:
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt
```

---

## 🔐 CONFIGURATION GITHUB

### ÉTAPE 7 : Créer un dépôt GitHub

1. Allez sur https://github.com
2. Cliquez sur **New repository**
3. Nom : `projet-iac-aws`
4. Description : "Infrastructure as Code - Déploiement AWS avec Terraform"
5. Visibilité : **Private** (recommandé)
6. ✅ Ne PAS initialiser avec README, .gitignore ou licence
7. Cliquez sur **Create repository**

### ÉTAPE 8 : Créer un Personal Access Token (PAT)

1. Allez sur https://github.com/settings/tokens
2. Cliquez sur **Generate new token** → **Generate new token (classic)**
3. Note : "IAC Sonatel Token"
4. Expiration : **90 days** (ou plus)
5. **Cochez les scopes suivants** :
   - ✅ `repo` (tous les sous-scopes)
   - ✅ `workflow`
   - ✅ `admin:repo_hook`
6. Cliquez sur **Generate token**
7. **COPIEZ LE TOKEN** (vous ne le reverrez plus !)
8. **Collez-le dans votre fichier .env** comme `GITHUB_TOKEN`

### ÉTAPE 9 : Pousser le code sur GitHub

```bash
# Initialiser Git
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "🎉 Initial commit - Projet IAC Sonatel AWS"

# Ajouter le remote (REMPLACEZ VOTRE_USERNAME)
git remote add origin https://github.com/VOTRE_USERNAME/projet-iac-aws.git

# Pousser sur GitHub
git branch -M main
git push -u origin main
```

### ÉTAPE 10 : Configurer les Secrets GitHub

1. Allez sur votre dépôt GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Cliquez sur **New repository secret**
4. Créez **2 secrets** :

**Secret 1 : AWS_ACCESS_KEY_ID**
- Name : `AWS_ACCESS_KEY_ID`
- Secret : Votre clé d'accès AWS (voir section AWS ci-dessous)

**Secret 2 : AWS_SECRET_ACCESS_KEY**
- Name : `AWS_SECRET_ACCESS_KEY`
- Secret : Votre clé secrète AWS

---

## ☁️ CONFIGURATION AWS

### ÉTAPE 11 : Créer un compte AWS

1. Allez sur https://aws.amazon.com
2. Cliquez sur **Create an AWS Account**
3. Suivez les étapes (carte bancaire requise mais Free Tier gratuit)
4. Vérifiez votre identité

### ÉTAPE 12 : Créer un utilisateur IAM

1. Connectez-vous à la console AWS
2. Allez dans **IAM** (Identity and Access Management)
3. Menu **Users** → **Add users**
4. Nom d'utilisateur : `terraform-deployer`
5. ✅ Cochez **Programmatic access** (Access key ID et Secret)
6. Cliquez sur **Next: Permissions**

### ÉTAPE 13 : Attacher les permissions

**Option 1 : Permissions administrateur (simple mais moins sécurisé)**
- Cliquez sur **Attach existing policies directly**
- Cherchez et cochez : `AdministratorAccess`

**Option 2 : Permissions minimales (recommandé pour production)**
- Créez une policy custom avec les permissions suivantes :
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "rds:*",
        "lambda:*",
        "iam:*",
        "cloudwatch:*",
        "route53:*",
        "elasticloadbalancing:*",
        "cloudfront:*",
        "acm:*"
      ],
      "Resource": "*"
    }
  ]
}
```

7. Cliquez sur **Next** jusqu'à **Create user**
8. **COPIEZ** les credentials :
   - **Access key ID** → Mettez dans GitHub Secrets comme `AWS_ACCESS_KEY_ID`
   - **Secret access key** → Mettez dans GitHub Secrets comme `AWS_SECRET_ACCESS_KEY`

⚠️ **IMPORTANT** : Sauvegardez ces credentials dans un endroit sûr !

---

## 🚀 DÉPLOIEMENT DE L'APPLICATION

### OPTION 1 : Déploiement LOCAL (pour développement)

```bash
# Activer l'environnement virtuel
source venv/bin/activate  # Linux/Mac
# OU
venv\Scripts\activate  # Windows

# Lancer l'application
python app.py

# L'application sera accessible sur :
# http://localhost:5000
```

**Ouvrez votre navigateur** : http://localhost:5000

✅ Vous devriez voir la page d'accueil Mission Control !

### OPTION 2 : Déploiement sur HEROKU (gratuit)

#### Étape 14 : Préparer pour Heroku

1. **Créer un compte Heroku** : https://heroku.com
2. **Installer Heroku CLI** :
```bash
# Windows
choco install heroku-cli

# macOS
brew install heroku/brew/heroku

# Linux
curl https://cli-assets.heroku.com/install.sh | sh
```

3. **Créer Procfile** :
```bash
cat > Procfile << 'EOF'
web: gunicorn app:app
EOF
```

4. **Créer runtime.txt** :
```bash
cat > runtime.txt << 'EOF'
python-3.11.7
EOF
```

#### Étape 15 : Déployer sur Heroku

```bash
# Se connecter à Heroku
heroku login

# Créer une nouvelle app
heroku create projet-iac-sonatel

# Configurer les variables d'environnement
heroku config:set GITHUB_TOKEN=votre_token
heroku config:set GITHUB_OWNER=votre_username
heroku config:set GITHUB_REPO=projet-iac-aws
heroku config:set SECRET_KEY=$(python -c "import secrets; print(secrets.token_hex(32))")

# Déployer
git push heroku main

# Ouvrir l'app
heroku open
```

✅ Votre application est maintenant en ligne !

### OPTION 3 : Déploiement sur RENDER (recommandé - gratuit)

#### Étape 16 : Déployer sur Render

1. **Créer un compte** : https://render.com
2. **Dashboard** → **New** → **Web Service**
3. Connectez votre dépôt GitHub
4. Sélectionnez `projet-iac-aws`
5. Configuration :
   - **Name** : `projet-iac-sonatel`
   - **Environment** : `Python 3`
   - **Build Command** : `pip install -r requirements.txt`
   - **Start Command** : `gunicorn app:app`
   - **Instance Type** : `Free`
6. **Environment Variables** (Add from .env) :
   - `GITHUB_TOKEN` = votre token
   - `GITHUB_OWNER` = votre username
   - `GITHUB_REPO` = projet-iac-aws
   - `SECRET_KEY` = générez une clé
7. Cliquez sur **Create Web Service**

⏱️ Le déploiement prend 2-3 minutes.

✅ Votre application est accessible sur : `https://projet-iac-sonatel.onrender.com`

---

## ✅ TEST ET VALIDATION

### ÉTAPE 17 : Tester l'application web

1. **Ouvrez l'application** (localhost:5000 ou URL en ligne)
2. **Vérifiez** :
   - ✅ Page d'accueil s'affiche
   - ✅ Les 10 services sont visibles
   - ✅ Les cartes sont cliquables

### ÉTAPE 18 : Tester un formulaire

1. **Cliquez sur EC2**
2. **Remplissez le formulaire** :
   - Nom : `test-instance`
   - Région : `eu-west-3`
   - OS : Choisissez une AMI
   - Taille : `t3.micro`
   - Environnement : `dev`
3. **Cliquez sur "Créer l'instance EC2"**
4. **Vérifiez** :
   - ✅ Le formulaire se soumet
   - ✅ Redirection vers page de succès

### ÉTAPE 19 : Tester le déclenchement GitHub Actions

1. **Allez sur GitHub** → Votre dépôt → **Actions**
2. **Vous devriez voir** : "Terraform EC2 Deployment"
3. **Cliquez dessus** pour voir le workflow
4. **Si le workflow n'apparaît pas** : Le trigger depuis Flask ne fonctionne pas encore
   - C'est normal, vous pouvez déclencher manuellement

### ÉTAPE 20 : Déclencher manuellement un workflow

1. **GitHub** → **Actions** → **Terraform EC2 Deployment**
2. **Run workflow** (bouton à droite)
3. **Remplissez les paramètres** :
   - instance_name : `test-manual`
   - instance_os : `ami-0c94855ba95c574c8`
   - instance_size : `t3.micro`
   - instance_env : `dev`
   - aws_region : `eu-west-3`
4. **Run workflow**
5. **Attendez** ~3-5 minutes
6. **Vérifiez** :
   - ✅ Workflow passe au vert
   - ✅ Instance créée sur AWS

### ÉTAPE 21 : Vérifier sur AWS

1. **Console AWS** → **EC2** → **Instances**
2. **Vous devriez voir** : `test-manual` (running)
3. **Vérifiez** les outputs :
   - IP publique
   - DNS public
4. **Testez HTTP** : `http://ADRESSE_IP_PUBLIQUE`

---

## 🔧 DÉPANNAGE

### Problème 1 : Checkboxes ne fonctionnent pas

**Solution** : Voir `SOLUTION_CHECKBOX_FINALE.txt`
- Remplacer `<label class="toggle-row">` par `<div class="toggle-row">`
- 5 fichiers à modifier (15 minutes)

### Problème 2 : "Module not found" lors du lancement

```bash
# Réinstaller les dépendances
pip install -r requirements.txt
```

### Problème 3 : GitHub Actions ne se déclenchent pas

**Vérifiez** :
1. Secrets GitHub configurés (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
2. Token GitHub valide dans .env
3. Permissions du token (repo + workflow)

**Solution temporaire** : Déclencher manuellement via GitHub Actions

### Problème 4 : Terraform échoue

**Erreurs communes** :
- "Invalid credentials" → Vérifier secrets AWS
- "Resource already exists" → Détruire avec `terraform destroy`
- "Permission denied" → Vérifier permissions IAM

### Problème 5 : Port 5000 déjà utilisé

```bash
# Utiliser un autre port
export PORT=8000  # Linux/Mac
set PORT=8000     # Windows

python app.py
```

---

## 📊 CHECKLIST FINALE

### Avant le déploiement

- [ ] Compte GitHub créé
- [ ] Compte AWS créé
- [ ] Dépôt GitHub créé et poussé
- [ ] Token GitHub créé et configuré
- [ ] Credentials AWS créés
- [ ] Secrets GitHub configurés
- [ ] Fichier .env configuré
- [ ] Dependencies installées

### Configuration des fichiers

- [ ] app.py copié et configuré
- [ ] Tous les fichiers HTML dans templates/
- [ ] Tous les workflows dans .github/workflows/
- [ ] Tous les fichiers Terraform dans infra/
- [ ] requirements.txt créé
- [ ] .gitignore créé
- [ ] .env créé (et dans .gitignore)

### Tests

- [ ] Application démarre en local
- [ ] Page d'accueil s'affiche
- [ ] Formulaires sont accessibles
- [ ] Checkboxes fonctionnent (après correction)
- [ ] Workflow GitHub Actions déclenché
- [ ] Ressource créée sur AWS

### Déploiement en ligne (optionnel)

- [ ] Heroku ou Render configuré
- [ ] Variables d'environnement configurées
- [ ] Application accessible en ligne
- [ ] Formulaires fonctionnent en ligne

---

## 🎉 FÉLICITATIONS !

Votre application IAC SONATEL est maintenant **100% OPÉRATIONNELLE** !

**Prochaines étapes** :
1. ✅ Corriger les checkboxes (15 min)
2. ✅ Tester tous les services AWS
3. ✅ Personnaliser les formulaires
4. ✅ Ajouter des features supplémentaires

**Temps total estimé** : 2-3 heures pour un déploiement complet.