# ☁️ PROJET IAC SONATEL — AWS Management Console

**Infrastructure as Code unifiée pour 10 services AWS essentiels**

Interface web Flask + Terraform + GitHub Actions pour automatiser le déploiement
et la gestion de votre infrastructure AWS avec validation en temps réel et design Mission Control.

---

## 📐 Architecture globale

```
projet-iac-aws/
├── app.py                           ← Backend Flask unifié (10 services)
├── templates/
│   ├── index.html                   ← Page d'accueil (grille des services)
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
├── infra/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── s3/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── site/                    ← Fichiers du site statique
│   ├── rds/
│   ├── lambda/
│   ├── iam/
│   ├── vpc/
│   ├── cloudwatch/
│   ├── route53/
│   ├── elb/
│   └── cloudfront/
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
├── .env                             ← Variables d'environnement (NE PAS COMMITTER)
├── .gitignore
├── requirements.txt
└── README.md
```

---

## 🎯 Services disponibles

| # | Service | Description | Ressources Terraform créées |
|---|---------|-------------|----------------------------|
| 1 | **EC2** | Serveurs virtuels | `aws_instance`, `aws_security_group`, `aws_key_pair` |
| 2 | **S3** | Stockage objets | `aws_s3_bucket`, `aws_s3_bucket_website_configuration`, `aws_s3_object` |
| 3 | **RDS** | Bases de données | `aws_db_instance`, `aws_db_subnet_group`, `aws_db_parameter_group` |
| 4 | **Lambda** | Fonctions serverless | `aws_lambda_function`, `aws_lambda_permission`, `aws_iam_role` |
| 5 | **IAM** | Gestion accès | `aws_iam_user`, `aws_iam_group`, `aws_iam_role`, `aws_iam_policy` |
| 6 | **VPC** | Réseau virtuel | `aws_vpc`, `aws_subnet`, `aws_internet_gateway`, `aws_nat_gateway` |
| 7 | **CloudWatch** | Monitoring | `aws_cloudwatch_metric_alarm`, `aws_cloudwatch_dashboard`, `aws_cloudwatch_log_group` |
| 8 | **Route 53** | DNS | `aws_route53_zone`, `aws_route53_record`, `aws_route53_health_check` |
| 9 | **ELB** | Load balancing | `aws_lb`, `aws_lb_target_group`, `aws_lb_listener` |
| 10 | **CloudFront** | CDN | `aws_cloudfront_distribution`, `aws_cloudfront_origin_access_identity` |

---

## 📋 Prérequis

### Comptes et accès

- **Compte AWS** avec IAM User disposant des permissions suivantes :
  ```
  AmazonEC2FullAccess
  AmazonS3FullAccess
  AmazonRDSFullAccess
  AWSLambdaFullAccess
  IAMFullAccess
  AmazonVPCFullAccess
  CloudWatchFullAccess
  AmazonRoute53FullAccess
  ElasticLoadBalancingFullAccess
  CloudFrontFullAccess
  ```
  
- **Compte GitHub** (gratuit suffit)

### Logiciels locaux

- Python 3.8 ou supérieur
- Git
- Un éditeur de code (VS Code recommandé)

---

## 🔧 Installation — Guide pas à pas

### Étape 1 : Créer l'utilisateur IAM AWS

1. Connectez-vous à [AWS Console](https://console.aws.amazon.com/)
2. Allez dans **IAM** → **Users** → **Create user**
3. Nom d'utilisateur : `sonatel-iac-admin`
4. Cochez **Programmatic access**
5. **Attach policies directly** → Sélectionnez les 10 politiques listées ci-dessus
6. **Create user**
7. **⚠️ IMPORTANT** : Copiez `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY`

> 💡 **Alternative** : Créez une politique IAM personnalisée avec seulement les permissions nécessaires
> (principe du moindre privilège) en vous basant sur les actions Terraform de chaque service.

### Étape 2 : Créer le dépôt GitHub

1. Allez sur [GitHub](https://github.com/)
2. **New repository**
3. Nom : `projet-iac-aws`
4. Visibilité : Public ou Private selon vos besoins
5. **NE PAS** initialiser avec README (on va le pousser depuis local)
6. **Create repository**

### Étape 3 : Générer un Personal Access Token GitHub

1. GitHub → **Settings** (votre profil) → **Developer settings**
2. **Personal access tokens** → **Tokens (classic)** → **Generate new token (classic)**
3. Note : `IAC AWS Deployment Token`
4. Expiration : 90 jours (ou "No expiration" si vous êtes le seul utilisateur)
5. Permissions :
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
6. **Generate token**
7. **⚠️ COPIEZ LE TOKEN** (format `ghp_xxxxxxxxxxxxx`) — vous ne le reverrez plus !

### Étape 4 : Configurer les Secrets GitHub

1. Allez dans votre dépôt GitHub → **Settings** → **Secrets and variables** → **Actions**
2. Cliquez sur **New repository secret**
3. Créez ces 2 secrets :

| Nom du secret | Valeur |
|---------------|--------|
| `AWS_ACCESS_KEY_ID` | Votre clé AWS (ex: `AKIAIOSFODNN7EXAMPLE`) |
| `AWS_SECRET_ACCESS_KEY` | Votre clé secrète AWS (40 caractères) |

### Étape 5 : Cloner et initialiser le projet

```bash
# Créer le dossier du projet
mkdir projet-iac-aws
cd projet-iac-aws

# Initialiser Git
git init
git remote add origin https://github.com/VOTRE_USERNAME/projet-iac-aws.git

# Créer la structure de dossiers
mkdir -p templates infra/{ec2,s3,rds,lambda,iam,vpc,cloudwatch,route53,elb,cloudfront} .github/workflows

# Créer le fichier .gitignore
cat > .gitignore << 'EOF'
.env
__pycache__/
*.pyc
.DS_Store
*.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl
infra/*/terraform.tfvars
EOF
```

### Étape 6 : Configurer les variables d'environnement

Créez un fichier `.env` à la racine du projet :

```env
GITHUB_TOKEN=ghp_VOTRE_TOKEN_ICI
GITHUB_OWNER=VOTRE_USERNAME_GITHUB
GITHUB_REPO=projet-iac-aws
```

> ⚠️ **IMPORTANT** : Le fichier `.env` ne doit **JAMAIS** être commité sur GitHub.
> Vérifiez qu'il est bien dans `.gitignore`.

### Étape 7 : Installer les dépendances Python

Créez un fichier `requirements.txt` :

```txt
flask>=3.0.0
requests>=2.31.0
python-dotenv>=1.0.0
```

Installez les dépendances :

```bash
pip install -r requirements.txt
# ou avec un environnement virtuel (recommandé):
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Étape 8 : Copier les fichiers du projet

Copiez tous les fichiers fournis dans leur emplacement respectif :

```bash
# Backend Flask
cp app.py .

# Templates HTML
cp templates/*.html templates/

# Fichiers Terraform pour chaque service
cp infra/ec2/*.tf infra/ec2/
cp infra/s3/*.tf infra/s3/
# ... et ainsi de suite pour les 10 services

# Workflows GitHub Actions
cp .github/workflows/*.yml .github/workflows/
```

### Étape 9 : Pousser le code sur GitHub

```bash
git add .
git commit -m "Initial commit - AWS Management Console IAC"
git branch -M main
git push -u origin main
```

### Étape 10 : Lancer l'application

```bash
python app.py
```

Ouvrez votre navigateur : **http://localhost:5000**

---

## 🖥️ Utilisation de l'interface

### Page d'accueil

La page d'accueil affiche une grille de **10 cartes de services** avec :
- Icône colorée distinctive pour chaque service
- Nom et catégorie (COMPUTE, STORAGE, DATABASE...)
- Description succincte
- Tags des fonctionnalités clés

Cliquez sur un service pour accéder à son formulaire de déploiement.

### Formulaires de déploiement

Chaque service dispose d'un formulaire dédié avec :

✅ **Validation en temps réel** des champs  
✅ **Preview des ressources** créées  
✅ **Stepper visuel** de progression  
✅ **Documentation inline** (tooltips, hints)  
✅ **Confirmation** pour les environnements de production  

### Workflow de déploiement

1. Remplissez le formulaire
2. Validez les champs (la validation est côté client ET serveur)
3. Cliquez sur "Déployer" / "Créer"
4. L'application Flask déclenche le workflow GitHub Actions correspondant
5. Page de succès avec lien vers GitHub Actions
6. Suivez l'exécution en temps réel sur GitHub

---

## 📚 Documentation par service

### 1️⃣ EC2 — Elastic Compute Cloud

**Ce qui est créé :**
- 1x `aws_instance` (serveur virtuel)
- 1x `aws_security_group` (pare-feu avec règles SSH, HTTP, HTTPS)
- Utilise le VPC par défaut et un subnet existant

**Champs du formulaire :**
- **Nom de l'instance** : Nom unique (alphanumériques, tirets, underscores)
- **Système d'exploitation** : Choisir un AMI (Amazon Linux 2023, Ubuntu 22.04, Debian 12)
- **Taille de l'instance** : t3.micro (Free Tier), t3.small, t3.medium, t3.large
- **Environnement** : dev / preprod / prod

**Validations :**
- Nom : 1-50 caractères, regex `^[a-zA-Z0-9_-]+$`
- AMI : doit commencer par `ami-`
- Type d'instance : liste prédéfinie

**Outputs Terraform :**
```hcl
instance_id
instance_public_ip
instance_private_ip
instance_public_dns
security_group_id
ssh_command  # Ex: ssh -i key.pem ec2-user@IP
```

**Accès SSH :**
- Vous devrez créer une **Key Pair** dans la console AWS
- Téléchargez le fichier `.pem`
- Modifiez le Terraform pour inclure `key_name = "votre-cle"`

**Coût estimé :**
- t3.micro : ~$0.0104/heure = ~$7.50/mois (750h/mois gratuits la 1ère année)

---

### 2️⃣ S3 — Simple Storage Service

**Ce qui est créé :**
- 1x `aws_s3_bucket` (compartiment de stockage)
- 1x `aws_s3_bucket_public_access_block` (désactive les protections publiques)
- 1x `aws_s3_bucket_website_configuration` (hébergement web statique)
- 1x `aws_s3_bucket_policy` (autorisation GetObject publique)
- 1x `aws_s3_bucket_versioning`
- 1x `aws_s3_bucket_cors_configuration`
- Nx `aws_s3_object` (fichiers uploadés)

**⚠️ POINT CRITIQUE — Accès Public :**

Pour héberger un site web statique, **les 4 options suivantes DOIVENT être à `false`** :
```hcl
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false  # ← OBLIGATOIRE
  block_public_policy     = false  # ← OBLIGATOIRE
  ignore_public_acls      = false  # ← OBLIGATOIRE
  restrict_public_buckets = false  # ← OBLIGATOIRE
}
```

**Champs du formulaire :**
- **Nom du bucket** : 3-63 caractères, minuscules + tirets uniquement, globalement unique
- **Région** : eu-west-3 (Paris), us-east-1 (Virginie)...
- **Environnement** : dev / preprod / prod
- **Versioning** : Enabled / Disabled / Suspended
- **Storage Class** : STANDARD, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING
- **Index document** : index.html (par défaut)
- **Error document** : error.html (pour les 404)
- **Fichiers du site** : Upload multiple (HTML, CSS, JS, images...)

**Validations :**
- Nom : regex `^[a-z0-9][a-z0-9\-]{1,61}[a-z0-9]$`
- Pas de double tiret `--`
- Pas de format IP (192.168.1.1)
- Index document doit être présent dans les fichiers uploadés

**Outputs Terraform :**
```hcl
bucket_id
bucket_arn
website_url  # Ex: http://mon-bucket.s3-website.eu-west-3.amazonaws.com
files_uploaded  # Nombre de fichiers
```

**Coût estimé :**
- Stockage : $0.023/GB/mois (STANDARD)
- Requêtes GET : $0.0004 par 1000 requêtes
- 5GB stockage + 20 000 requêtes gratuits la 1ère année

---

### 3️⃣ RDS — Relational Database Service

**Ce qui est créé :**
- 1x `aws_db_instance` (instance de base de données)
- 1x `aws_db_subnet_group` (groupe de subnets pour Multi-AZ)
- 1x `aws_db_parameter_group` (paramètres du moteur)
- 1x `aws_security_group` (autorisation des connexions entrantes)

**Moteurs supportés :**
- MySQL 8.0
- PostgreSQL 15
- MariaDB 10.11
- Oracle (selon licence)
- SQL Server (selon édition)

**Champs du formulaire :**
- **DB Identifier** : Nom unique (alphanumériques + tirets)
- **Moteur** : mysql / postgres / mariadb
- **Version** : 8.0.35, 15.4...
- **Instance Class** : db.t3.micro (Free Tier), db.t3.small, db.m5.large...
- **Storage** : 20-65536 GB (SSD gp3 recommandé)
- **Nom de la BDD** : Nom de la base initiale (optionnel)
- **Username** : Utilisateur administrateur (3-16 caractères)
- **Password** : Mot de passe (auto-généré sécurisé ou fourni)
- **Multi-AZ** : true/false (haute disponibilité)
- **Backups** : Rétention 1-35 jours
- **Encryption** : Activé par défaut

**Validations :**
- Identifier : 1-63 caractères, `^[a-z][a-z0-9\-]*$`
- Username : pas de mots réservés SQL
- Password : min 8 caractères, complexité AWS

**Outputs Terraform :**
```hcl
db_endpoint  # Ex: mydb.c9abc123.eu-west-3.rds.amazonaws.com:3306
db_arn
db_name
db_username
db_connection_string  # Chaîne de connexion formatée
```

**Connexion à la BDD :**
```bash
# MySQL
mysql -h ENDPOINT -u USERNAME -p

# PostgreSQL
psql -h ENDPOINT -U USERNAME -d DBNAME
```

**Coût estimé :**
- db.t3.micro : ~$15/mois (750h gratuits la 1ère année)
- Stockage : $0.115/GB/mois (gp3)

---

### 4️⃣ Lambda — Fonctions Serverless

**Ce qui est créé :**
- 1x `aws_lambda_function` (fonction exécutable)
- 1x `aws_iam_role` (rôle d'exécution avec politiques attachées)
- 1x `aws_iam_role_policy_attachment` (CloudWatch Logs)
- 1x `aws_cloudwatch_log_group` (pour les logs)
- (Optionnel) `aws_lambda_permission` pour API Gateway, S3, EventBridge...

**Runtimes supportés :**
- Python 3.11, 3.10, 3.9
- Node.js 20.x, 18.x
- Java 17, 11
- Go 1.x
- .NET 7, 6
- Ruby 3.2

**Champs du formulaire :**
- **Nom de la fonction** : Nom unique (alphanumériques + tirets/underscores)
- **Runtime** : python3.11, nodejs20.x...
- **Handler** : Point d'entrée (ex: `lambda_function.lambda_handler`)
- **Code source** :
  - Upload ZIP (< 50 MB direct, sinon via S3)
  - Ou code inline pour les petites fonctions
- **Mémoire** : 128 MB - 10240 MB (par pas de 1 MB)
- **Timeout** : 3 - 900 secondes
- **Variables d'environnement** : Paires clé=valeur (chiffrées au repos)
- **VPC** : Optionnel (si connexion à RDS/ElastiCache requis)
- **Triggers** : API Gateway, S3, EventBridge, SQS...

**Validations :**
- Nom : 1-64 caractères, `^[a-zA-Z0-9_-]+$`
- Handler : format `file.function`
- Code ZIP : max 50 MB (ou 250 MB via S3)

**Exemple de fonction Python :**
```python
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
```

**Outputs Terraform :**
```hcl
function_name
function_arn
function_invoke_arn  # Pour API Gateway
function_version
log_group_name
```

**Invocation :**
```bash
aws lambda invoke --function-name ma-fonction output.json
```

**Coût estimé :**
- 1 million de requêtes/mois GRATUITES
- $0.20 par million de requêtes au-delà
- $0.0000166667 par GB-seconde de compute

---

### 5️⃣ IAM — Identity and Access Management

**Ce qui est créé :**
- `aws_iam_user` (utilisateurs)
- `aws_iam_group` (groupes)
- `aws_iam_role` (rôles pour services AWS)
- `aws_iam_policy` (politiques personnalisées)
- `aws_iam_user_group_membership` (attachements)
- `aws_iam_policy_attachment` (permissions)

**Champs du formulaire :**
- **Type de ressource** : User / Group / Role / Policy
- **Nom** : Unique dans le compte AWS
- **Path** : Chemin organisationnel (ex: `/dev/`)
- **Permissions** :
  - Politiques AWS managées (ReadOnlyAccess, PowerUserAccess...)
  - Politiques inline (JSON)
- **MFA** : Activation recommandée pour les utilisateurs

**Exemple de politique JSON :**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::my-bucket/*"
  }]
}
```

**Validations :**
- Nom : 1-128 caractères, `^[a-zA-Z0-9+=,.@_-]+$`
- Policy JSON : valide selon la syntaxe AWS

**Outputs Terraform :**
```hcl
user_arn
group_arn
role_arn
policy_arn
access_key_id  # ⚠️ Sensible, gérer via secrets
```

**⚠️ Sécurité :**
- **Jamais de credentials en clair** dans le code
- Utilisez AWS Secrets Manager ou Parameter Store
- Activez CloudTrail pour l'audit

**Coût :**
- IAM est **gratuit** (pas de coût direct)

---

### 6️⃣ VPC — Virtual Private Cloud

**Ce qui est créé :**
- 1x `aws_vpc` (réseau privé virtuel)
- 2x `aws_subnet` (public + privé dans chaque AZ)
- 1x `aws_internet_gateway` (connexion Internet)
- 1x `aws_nat_gateway` (pour subnets privés)
- 1x `aws_eip` (Elastic IP pour NAT)
- 2x `aws_route_table` (routes publiques + privées)
- 4x `aws_route_table_association`

**Champs du formulaire :**
- **Nom du VPC** : Identifiant unique
- **CIDR Block** : 10.0.0.0/16, 172.16.0.0/12, 192.168.0.0/16
- **Availability Zones** : 2 ou 3 AZ (haute disponibilité)
- **Subnets publics** : Pour instances avec IP publiques
- **Subnets privés** : Pour RDS, ElastiCache...
- **NAT Gateway** : Activé (payant) ou NAT Instance (économique)
- **VPC Endpoints** : S3, DynamoDB (gratuits, améliorent perf)

**Topologie typique :**
```
VPC 10.0.0.0/16
├── Public Subnet 1a:  10.0.1.0/24  (IGW)
├── Public Subnet 1b:  10.0.2.0/24  (IGW)
├── Private Subnet 1a: 10.0.11.0/24 (NAT)
└── Private Subnet 1b: 10.0.12.0/24 (NAT)
```

**Validations :**
- CIDR : format IPv4 valide
- Subnets : ne doivent pas se chevaucher

**Outputs Terraform :**
```hcl
vpc_id
vpc_cidr_block
public_subnet_ids
private_subnet_ids
internet_gateway_id
nat_gateway_id
```

**Coût estimé :**
- VPC, Subnets, IGW : **GRATUITS**
- NAT Gateway : $0.045/heure + $0.045/GB transféré = ~$32/mois

---

### 7️⃣ CloudWatch — Monitoring et Logs

**Ce qui est créé :**
- `aws_cloudwatch_metric_alarm` (alarmes sur métriques)
- `aws_cloudwatch_dashboard` (tableaux de bord personnalisés)
- `aws_cloudwatch_log_group` (groupes de logs)
- `aws_cloudwatch_log_stream` (flux de logs)
- `aws_cloudwatch_event_rule` (EventBridge pour automatisation)

**Champs du formulaire :**
- **Type de ressource** : Alarm / Dashboard / Log Group
- **Nom** : Identifiant
- **Métrique à surveiller** :
  - EC2: CPUUtilization, DiskReadBytes...
  - RDS: DatabaseConnections, FreeableMemory...
  - Lambda: Invocations, Errors, Duration...
- **Seuil d'alerte** : Valeur déclenchant l'alarme
- **Période** : 1 min, 5 min, 1 heure...
- **Actions SNS** : Envoyer email/SMS via SNS topic

**Exemple d'alarme :**
```hcl
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

**Outputs Terraform :**
```hcl
alarm_arn
dashboard_arn
log_group_name
```

**Coût estimé :**
- 10 métriques personnalisées GRATUITES
- $0.30 par métrique au-delà
- Logs : $0.50/GB ingérés

---

### 8️⃣ Route 53 — DNS Management

**Ce qui est créé :**
- `aws_route53_zone` (zone DNS hébergée)
- `aws_route53_record` (enregistrements A, AAAA, CNAME, MX, TXT...)
- `aws_route53_health_check` (surveillance de disponibilité)
- `aws_route53_traffic_policy` (routage complexe)

**Champs du formulaire :**
- **Nom de domaine** : example.com (vous devez posséder le domaine)
- **Type de zone** : Public / Private (VPC)
- **Enregistrements** :
  - **A** : IPv4 (ex: @ → 203.0.113.1)
  - **AAAA** : IPv6
  - **CNAME** : Alias (ex: www → example.com)
  - **MX** : Mail servers
  - **TXT** : Vérification domaine, SPF, DKIM
- **TTL** : Time To Live (300s par défaut)
- **Politique de routage** :
  - Simple
  - Weighted (répartition pondérée)
  - Latency (plus faible latence)
  - Failover (basculement automatique)
  - Geolocation (par pays/continent)

**Validations :**
- Nom de domaine : format DNS valide
- Valeur enregistrement : selon le type (IP, domaine...)

**Outputs Terraform :**
```hcl
zone_id
zone_name_servers  # NS à configurer chez votre registrar
record_fqdn
health_check_id
```

**Configuration initiale :**
1. Créez la zone dans Route 53
2. Récupérez les 4 serveurs NS (ex: ns-123.awsdns-12.com)
3. Configurez-les chez votre registrar (Namecheap, OVH...)
4. Attendez la propagation DNS (jusqu'à 48h)

**Coût estimé :**
- Zone hébergée : $0.50/mois
- 1 million de requêtes : $0.40

---

### 9️⃣ ELB — Elastic Load Balancing

**Ce qui est créé :**
- `aws_lb` (Application Load Balancer ou Network Load Balancer)
- `aws_lb_target_group` (groupe de cibles — instances EC2, IPs, Lambda)
- `aws_lb_listener` (port 80, 443 avec règles de routage)
- `aws_lb_listener_rule` (routage basé sur path, host, headers...)
- `aws_lb_target_group_attachment` (enregistrement des targets)

**Types de Load Balancers :**
- **ALB** (Application) : HTTP/HTTPS, Layer 7, routage avancé
- **NLB** (Network) : TCP/UDP, Layer 4, ultra performant
- **CLB** (Classic) : Legacy, non recommandé

**Champs du formulaire :**
- **Nom du LB** : Unique dans la région
- **Type** : application / network
- **Schéma** : internet-facing / internal
- **Subnets** : Sélectionner 2+ AZ (haute disponibilité)
- **Security Groups** : Autoriser ports 80, 443
- **Listeners** :
  - HTTP :80 → Target Group
  - HTTPS :443 → Target Group (nécessite certificat ACM)
- **Target Group** :
  - Protocol : HTTP, HTTPS, TCP
  - Port : 80, 443, 3000...
  - Health check : /health, /, /api/ping...
- **Targets** : Instances EC2 à ajouter

**Validations :**
- Nom : 1-32 caractères, alphanumériques + tirets
- Au moins 2 subnets dans des AZ différents

**Outputs Terraform :**
```hcl
lb_arn
lb_dns_name  # Ex: my-lb-1234567890.eu-west-3.elb.amazonaws.com
lb_zone_id
target_group_arn
```

**Accès à l'application :**
```
http://my-lb-1234567890.eu-west-3.elb.amazonaws.com
```

Pour un domaine personnalisé, créez un enregistrement CNAME dans Route 53 :
```
www.example.com  CNAME  my-lb-1234567890.eu-west-3.elb.amazonaws.com
```

**Coût estimé :**
- ALB : $0.0225/heure + $0.008/LCU-heure = ~$20/mois
- NLB : $0.0225/heure + $0.006/NLCU-heure = ~$18/mois

---

### 🔟 CloudFront — Content Delivery Network

**Ce qui est créé :**
- `aws_cloudfront_distribution` (distribution CDN)
- `aws_cloudfront_origin_access_identity` (OAI pour S3 sécurisé)
- `aws_cloudfront_cache_policy` (politiques de cache)
- `aws_cloudfront_origin_request_policy`

**Champs du formulaire :**
- **Origine** :
  - S3 bucket (site statique)
  - ALB (application dynamique)
  - Custom origin (votre serveur)
- **Nom de domaine alternatif** : www.example.com (optionnel)
- **Certificat SSL** : AWS Certificate Manager (ACM) — région us-east-1 obligatoire
- **Comportements de cache** :
  - Path patterns : /images/*, /api/*
  - TTL : Minimum, Default, Maximum (en secondes)
  - Méthodes HTTP : GET, HEAD / GET, HEAD, OPTIONS / ALL
  - Compress objects : Activé (gzip, brotli)
- **Restrictions géographiques** : Whitelist/Blacklist de pays
- **Logging** : Activer les logs d'accès (vers S3)

**Exemple de configuration S3 → CloudFront :**
```hcl
origin {
  domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
  origin_id   = "S3-${aws_s3_bucket.static_site.id}"

  s3_origin_config {
    origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
  }
}
```

**Validations :**
- Domaine alternatif : certificat ACM dans us-east-1
- Origine S3 : bucket doit exister

**Outputs Terraform :**
```hcl
distribution_id
distribution_arn
distribution_domain_name  # Ex: d123456abcdef.cloudfront.net
distribution_status
```

**Configuration DNS :**
```
www.example.com  CNAME  d123456abcdef.cloudfront.net
```

Ou avec Route 53 Alias (recommandé) :
```
www.example.com  A  ALIAS  d123456abcdef.cloudfront.net
```

**Invalidation du cache :**
```bash
aws cloudfront create-invalidation \
  --distribution-id D123456ABCDEF \
  --paths "/*"
```

**Coût estimé :**
- 1 TB sortant : $85/mois (varie selon régions)
- 10M requêtes HTTP : $10
- Invalidations : 1000 paths gratuits/mois

---

## 🔐 Sécurité et bonnes pratiques

### Principe du moindre privilège

- Créez des politiques IAM **spécifiques** à chaque service
- N'utilisez **jamais** les credentials root
- Activez **MFA** sur tous les comptes utilisateurs
- Utilisez **IAM Roles** pour les services AWS (pas de clés codées en dur)

### Gestion des secrets

- **NE JAMAIS** committer :
  - `.env` (tokens GitHub, credentials AWS)
  - `terraform.tfvars` (mots de passe, clés)
  - Clés privées SSH (`.pem`)
- Utilisez **AWS Secrets Manager** ou **Parameter Store** pour les secrets
- Chiffrez les variables sensibles avec **KMS**

### Réseau

- Subnets privés pour RDS, ElastiCache
- Security Groups avec règles **strictes** (pas de `0.0.0.0/0` en entrée sauf ALB)
- VPC Flow Logs pour l'audit du trafic

### Backups et résilience

- **RDS** : Automated backups + snapshots manuels
- **S3** : Versioning activé en production
- **Multi-AZ** pour RDS, ELB
- **CloudWatch Alarms** sur toutes les ressources critiques

### Coûts

- Activez **AWS Budgets** avec alertes email
- Utilisez **AWS Cost Explorer** mensuellement
- Supprimez les ressources inutilisées (EBS volumes, Elastic IPs...)
- Tagguez **toutes** les ressources pour le cost tracking

---

## 📊 Monitoring et observabilité

### CloudWatch

- **Métriques custom** pour votre application
- **Dashboards** par environnement (prod, staging, dev)
- **Alarmes** sur :
  - EC2: CPU > 80%, StatusCheckFailed
  - RDS: FreeStorageSpace < 10GB, CPUUtilization > 80%
  - Lambda: Errors > 5, Duration > timeout-50ms
  - ELB: UnHealthyHostCount > 0, TargetResponseTime > 3s

### Logs

- **CloudWatch Logs** : Centralisation de tous les logs applicatifs
- **Log Insights** : Requêtes SQL pour analyser les logs
- **Rétention** : 7 jours (dev), 30 jours (staging), 90 jours (prod)

### Tracing

- **AWS X-Ray** pour le tracing distribué (Lambda, API Gateway, ECS)

---

## 🐛 Débogage

### Erreur : "Credentials invalid"

```
Error: error configuring Terraform AWS Provider: error validating provider credentials
```

**Solution :**
1. Vérifiez que les secrets GitHub sont bien configurés
2. Testez les credentials localement :
   ```bash
   aws configure
   aws sts get-caller-identity
   ```
3. Assurez-vous que l'utilisateur IAM a les bonnes permissions

### Erreur : "Resource already exists"

```
Error: Error creating [Resource]: [Resource] already exists
```

**Solution :**
1. Vérifiez que le nom est unique
2. Pour importer une ressource existante :
   ```bash
   terraform import aws_instance.example i-1234567890abcdef0
   ```

### Erreur : "Timeout waiting for state"

```
Error: timeout while waiting for state to become 'available'
```

**Solution :**
- Augmentez le timeout dans le workflow GitHub Actions
- Vérifiez les quotas AWS (Service Quotas)

### Workflow GitHub Actions ne se déclenche pas

**Solution :**
1. Vérifiez que le token a les permissions `workflow`
2. Vérifiez le nom du workflow dans `WORKFLOWS` (app.py)
3. Regardez les logs du serveur Flask pour le status code de la réponse API

---

## 📈 Évolutions futures

- [ ] Ajout de Auto Scaling Groups pour EC2
- [ ] Support de ECS/Fargate pour les conteneurs
- [ ] DynamoDB pour les bases NoSQL
- [ ] SNS/SQS pour la messagerie
- [ ] API Gateway REST/WebSocket
- [ ] Cognito pour l'authentification
- [ ] Step Functions pour les workflows
- [ ] Backup automatisé avec AWS Backup
- [ ] Terraform state backend S3 + DynamoDB lock

---

## 🤝 Contribution

Les pull requests sont les bienvenues ! Pour des changements majeurs, ouvrez d'abord une issue.

---

## 📄 Licence

MIT License — Copyright (c) 2026 SONATEL IAC

---

## 🆘 Support

Pour toute question :
- Ouvrez une issue sur GitHub
- Email : mintok2000@gmail.com

---

**Projet maintenu avec AWS par Mohamed NDIAYE**
