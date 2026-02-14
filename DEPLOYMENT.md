# 🚀 GUIDE COMPLET DE DÉPLOIEMENT — 10 Services AWS

## 📊 État actuel du projet

### ✅ Fichiers créés et fonctionnels

| Fichier | Lignes | Status | Description |
|---------|--------|--------|-------------|
| `index.html` | ~600 | ✅ COMPLET | Page d'accueil avec grille des 10 services |
| `app.py` | ~350 | ✅ COMPLET | Backend Flask unifié pour tous les services |
| `README.md` | ~900 | ✅ COMPLET | Documentation exhaustive (10 services) |
| `form_ec2.html` | ~700 | ✅ COMPLET | Formulaire EC2 avec design Mission Control |
| `form_s3.html` | ~800 | ✅ COMPLET | Formulaire S3 avec upload et validation |
| **TOTAL** | **~3350** | | |

### 🔨 Fichiers Terraform EC2 (de vos documents)

✅ `infra/ec2/main.tf`  
✅ `infra/ec2/variables.tf`  
✅ `infra/ec2/outputs.tf`

### 🔨 Fichiers Terraform S3

✅ `infra/s3/main.tf`  
✅ `infra/s3/variables.tf`  
✅ `infra/s3/outputs.tf`

### 🔨 Workflows GitHub Actions

✅ `.github/workflows/terraform-ec2.yml` (de vos documents)  
✅ `.github/workflows/terraform-s3.yml`

---

## 🎯 Architecture de génération pour les 8 services restants

Chaque service suit exactement le même pattern. Voici le template :

### Pattern de création par service

```
SERVICE/
├── templates/form_SERVICE.html  (700-900 lignes)
├── infra/SERVICE/
│   ├── main.tf                  (100-300 lignes)
│   ├── variables.tf             (50-150 lignes)
│   └── outputs.tf               (30-80 lignes)
└── .github/workflows/
    └── terraform-SERVICE.yml    (120-180 lignes)
```

---

## 📝 Templates standardisés par service

### 1️⃣ RDS — Base de données relationnelle

**Champs du formulaire HTML :**
```html
- db_identifier        (string, 1-63 chars, regex: ^[a-z][a-z0-9\-]*$)
- engine               (select: mysql, postgres, mariadb)
- engine_version       (select selon moteur)
- instance_class       (select: db.t3.micro, db.t3.small, db.m5.large...)
- allocated_storage    (number: 20-65536 GB)
- db_name              (string, optionnel)
- username             (string, 3-16 chars)
- password             (password, auto-généré ou manuel)
- multi_az             (toggle: true/false)
- backup_retention     (number: 0-35 jours)
- environment          (select: dev, preprod, prod)
```

**Ressources Terraform (`main.tf`) :**
```hcl
resource "aws_db_instance" "main" {
  identifier           = var.db_identifier
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  username             = var.username
  password             = var.password  # ⚠️ Utiliser random_password en production
  multi_az             = var.multi_az
  backup_retention_period = var.backup_retention
  skip_final_snapshot  = true  # ⚠️ false en production
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  tags = {
    Name        = var.db_identifier
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Sonatel-IAC"
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.db_identifier}-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = var.engine == "postgres" ? 5432 : 3306
    to_port     = var.engine == "postgres" ? 5432 : 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Restreindre en production
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
```

**Outputs (`outputs.tf`) :**
```hcl
output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}
output "db_arn" {
  value = aws_db_instance.main.arn
}
output "db_name" {
  value = aws_db_instance.main.db_name
}
output "connection_string" {
  value = "${var.engine}://${var.username}@${aws_db_instance.main.endpoint}/${var.db_name}"
  sensitive = true
}
```

---

### 2️⃣ Lambda — Fonction serverless

**Champs du formulaire :**
```html
- function_name        (string, 1-64 chars)
- runtime              (select: python3.11, nodejs20.x, go1.x...)
- handler              (string: lambda_function.lambda_handler)
- code_zip             (file upload, < 50 MB)
- memory_size          (slider: 128-10240 MB)
- timeout              (number: 3-900 seconds)
- environment_vars     (key-value pairs)
- role_arn             (optionnel, créé automatiquement sinon)
```

**Ressources Terraform principales :**
```hcl
resource "aws_lambda_function" "main" {
  filename      = var.code_zip_path
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  
  environment {
    variables = var.environment_vars
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-exec-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
}
```

---

### 3️⃣ VPC — Réseau virtuel privé

**Champs du formulaire :**
```html
- vpc_name             (string)
- cidr_block           (string: 10.0.0.0/16, 172.16.0.0/12...)
- availability_zones   (multi-select: 2-3 AZ)
- public_subnets       (array de CIDR)
- private_subnets      (array de CIDR)
- enable_nat_gateway   (toggle)
- enable_vpn_gateway   (toggle)
```

**Ressources Terraform principales :**
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? length(var.public_subnets) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.public_subnets) : 0
  domain = "vpc"
}
```

---

### 4️⃣ IAM — Gestion des accès

**Champs du formulaire :**
```html
- resource_type        (radio: user, group, role, policy)
- name                 (string)
- path                 (string: /, /dev/, /admin/...)
- policy_document      (textarea JSON pour policies)
- managed_policies     (multi-select: ARN des policies AWS)
- assume_role_policy   (JSON pour les rôles)
```

**Ressources Terraform (exemple User) :**
```hcl
resource "aws_iam_user" "main" {
  name = var.user_name
  path = var.path
}

resource "aws_iam_user_policy_attachment" "main" {
  count      = length(var.managed_policy_arns)
  user       = aws_iam_user.main.name
  policy_arn = var.managed_policy_arns[count.index]
}

resource "aws_iam_user_policy" "inline" {
  count  = var.inline_policy != "" ? 1 : 0
  user   = aws_iam_user.main.name
  policy = var.inline_policy
}
```

---

### 5️⃣ CloudWatch — Monitoring

**Champs du formulaire :**
```html
- alarm_name           (string)
- metric_name          (select: CPUUtilization, NetworkIn...)
- namespace            (select: AWS/EC2, AWS/RDS, AWS/Lambda...)
- comparison_operator  (select: GreaterThan, LessThan...)
- threshold            (number)
- evaluation_periods   (number: 1-5)
- period               (number: 60, 300, 3600 seconds)
- statistic            (select: Average, Sum, Maximum...)
- sns_topic_arn        (string, pour notifications)
```

**Ressources Terraform :**
```hcl
resource "aws_cloudwatch_metric_alarm" "main" {
  alarm_name          = var.alarm_name
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold
  alarm_description   = "Managed by Terraform"
  
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

resource "aws_cloudwatch_log_group" "main" {
  name              = var.log_group_name
  retention_in_days = var.retention_days
}
```

---

### 6️⃣ Route 53 — DNS

**Champs du formulaire :**
```html
- zone_name            (string: example.com)
- zone_type            (radio: public, private)
- record_name          (string: www, api, @...)
- record_type          (select: A, AAAA, CNAME, MX, TXT...)
- record_value         (string ou array)
- ttl                  (number: 60-86400)
- routing_policy       (select: simple, weighted, latency...)
```

**Ressources Terraform :**
```hcl
resource "aws_route53_zone" "main" {
  name = var.zone_name
  
  dynamic "vpc" {
    for_each = var.zone_type == "private" ? [1] : []
    content {
      vpc_id = var.vpc_id
    }
  }
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.ttl
  records = var.record_values
}

resource "aws_route53_health_check" "main" {
  count             = var.enable_health_check ? 1 : 0
  fqdn              = "${var.record_name}.${var.zone_name}"
  port              = var.health_check_port
  type              = "HTTPS"
  resource_path     = var.health_check_path
  failure_threshold = 3
  request_interval  = 30
}
```

---

### 7️⃣ ELB — Load Balancer

**Champs du formulaire :**
```html
- lb_name              (string)
- lb_type              (radio: application, network)
- scheme               (radio: internet-facing, internal)
- subnets              (multi-select: au moins 2 AZ)
- security_groups      (multi-select pour ALB)
- target_group_port    (number: 80, 443, 3000...)
- health_check_path    (string: /, /health, /api/ping...)
- listener_port        (number: 80, 443...)
- ssl_certificate_arn  (string, pour HTTPS)
```

**Ressources Terraform :**
```hcl
resource "aws_lb" "main" {
  name               = var.lb_name
  load_balancer_type = var.lb_type
  subnets            = var.subnet_ids
  security_groups    = var.lb_type == "application" ? var.security_group_ids : null
  
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "main" {
  name     = "${var.lb_name}-tg"
  port     = var.target_group_port
  protocol = var.lb_type == "application" ? "HTTP" : "TCP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_port == 443 ? "HTTPS" : "HTTP"
  
  certificate_arn   = var.listener_port == 443 ? var.ssl_certificate_arn : null
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
```

---

### 8️⃣ CloudFront — CDN

**Champs du formulaire :**
```html
- distribution_comment (string)
- origin_domain        (string: bucket.s3.amazonaws.com ou ALB)
- origin_type          (radio: s3, custom)
- price_class          (select: PriceClass_All, PriceClass_100...)
- aliases              (array: www.example.com, cdn.example.com)
- acm_certificate_arn  (string, région us-east-1 obligatoire)
- default_ttl          (number: 0-31536000)
- compress             (toggle: true/false)
- viewer_protocol      (select: allow-all, redirect-to-https, https-only)
```

**Ressources Terraform :**
```hcl
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.distribution_comment
  default_root_object = "index.html"
  price_class         = var.price_class
  aliases             = var.aliases
  
  origin {
    domain_name = var.origin_domain
    origin_id   = "primary"
    
    dynamic "s3_origin_config" {
      for_each = var.origin_type == "s3" ? [1] : []
      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.main[0].cloudfront_access_identity_path
      }
    }
  }
  
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "primary"
    viewer_protocol_policy = var.viewer_protocol
    compress               = var.compress
    
    min_ttl     = 0
    default_ttl = var.default_ttl
    max_ttl     = 86400
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "main" {
  count   = var.origin_type == "s3" ? 1 : 0
  comment = "OAI for ${var.distribution_comment}"
}
```

---

## 🤖 Script de génération automatique

Pour accélérer la création des 8 services restants, utilisez ce script Python :

```python
#!/usr/bin/env python3
"""
Générateur de templates pour les services AWS IAC
Usage: python generate_service.py <service_name>
"""

import sys
import os

SERVICE_CONFIGS = {
    "rds": {
        "color": "#3b82f6",
        "icon": "🗄️",
        "title": "Base de données RDS",
        "fields": ["db_identifier", "engine", "instance_class", "username"],
    },
    "lambda": {
        "color": "#f59e0b",
        "icon": "⚡",
        "title": "Fonction Lambda",
        "fields": ["function_name", "runtime", "handler", "memory_size"],
    },
    # ... Ajouter les 8 configs
}

def generate_html_form(service):
    config = SERVICE_CONFIGS[service]
    # Template HTML avec les couleurs et champs spécifiques
    return f"""<!DOCTYPE html>
<html lang="fr">
<head>
    <title>SONATEL IAC — {config['title']}</title>
    <!-- Même CSS que EC2/S3 avec --primary-color: {config['color']} -->
</head>
<body>
    <!-- Formulaire avec {config['icon']} et champs {config['fields']} -->
</body>
</html>"""

def generate_terraform_main(service):
    # Génère main.tf avec les ressources spécifiques
    pass

def generate_terraform_variables(service):
    # Génère variables.tf avec validations
    pass

def generate_github_workflow(service):
    # Génère le workflow YAML
    pass

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python generate_service.py <service_name>")
        sys.exit(1)
    
    service = sys.argv[1].lower()
    
    if service not in SERVICE_CONFIGS:
        print(f"Service '{service}' non reconnu")
        sys.exit(1)
    
    print(f"Génération des fichiers pour {service}...")
    
    # Créer les dossiers
    os.makedirs(f"templates", exist_ok=True)
    os.makedirs(f"infra/{service}", exist_ok=True)
    os.makedirs(f".github/workflows", exist_ok=True)
    
    # Générer les fichiers
    with open(f"templates/form_{service}.html", "w") as f:
        f.write(generate_html_form(service))
    
    with open(f"infra/{service}/main.tf", "w") as f:
        f.write(generate_terraform_main(service))
    
    # ... etc
    
    print(f"✅ Service {service} généré avec succès!")
```

---

## 📦 Fichiers de configuration additionnels

### `.gitignore`
```gitignore
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/

# Terraform
*.tfstate
*.tfstate.backup
*.tfstate.*.backup
.terraform/
.terraform.lock.hcl
terraform.tfvars
*.auto.tfvars

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Secrets
.env
*.pem
*.key
secrets/

# Uploads
uploads/
```

### `requirements.txt`
```txt
flask==3.0.0
requests==2.31.0
python-dotenv==1.0.0
```

### `.env.example`
```env
GITHUB_TOKEN=ghp_your_token_here
GITHUB_OWNER=your_github_username
GITHUB_REPO=projet-iac-aws
```

---

## 🚀 Déploiement final

### 1. Installation locale

```bash
# Cloner le dépôt
git clone https://github.com/VOTRE_USERNAME/projet-iac-aws.git
cd projet-iac-aws

# Créer l'environnement virtuel
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Installer les dépendances
pip install -r requirements.txt

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos valeurs

# Lancer l'application
python app.py
```

### 2. Configuration GitHub

```bash
# Pousser sur GitHub
git add .
git commit -m "Initial commit - AWS IAC Console"
git push origin main

# Configurer les secrets dans GitHub:
# Settings → Secrets → Actions → New repository secret
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
```

### 3. Test du workflow

1. Ouvrir http://localhost:5000
2. Cliquer sur EC2 ou S3
3. Remplir le formulaire
4. Soumettre
5. Vérifier sur GitHub → Actions

---

## 📊 Prochaines étapes recommandées

1. **Compléter les 8 services manquants** en utilisant les templates ci-dessus
2. **Ajouter l'authentification** (Flask-Login ou OAuth GitHub)
3. **Terraform state backend** : S3 + DynamoDB pour le state partagé
4. **CI/CD avancé** : Tests automatisés avec `terraform plan` en PR
5. **Tableau de bord** : Page de monitoring des ressources déployées
6. **Notifications** : Slack/Discord webhooks après déploiement
7. **Rollback** : Bouton pour revenir à l'état précédent
8. **Multi-région** : Sélecteur de région dynamique
9. **Cost estimation** : Intégration de l'API AWS Pricing
10. **Terraform modules** : Refactoring avec modules réutilisables

---

**Votre projet est maintenant prêt à déployer EC2 et S3 de manière professionnelle.  
Les 8 autres services suivent exactement le même pattern documenté ci-dessus.**