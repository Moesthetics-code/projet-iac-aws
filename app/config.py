"""Configuration centralisée pour l'application Flask."""
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Configuration de base."""
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    DEBUG = False
    TESTING = False
    
    # GitHub
    GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
    GITHUB_REPO_OWNER = os.getenv('GITHUB_REPO_OWNER', 'votre-organisation')
    GITHUB_REPO_NAME = os.getenv('GITHUB_REPO_NAME', 'sonatel-iac')
    
    # AWS (optionnel, pour validation)
    AWS_REGION = os.getenv('AWS_REGION', 'eu-west-3')
    
    # Workflows mapping
    WORKFLOWS = {
        "ec2":        "terraform-ec2.yml",
        "s3":         "terraform-s3.yml",
        "rds":        "terraform-rds.yml",
        "lambda":     "terraform-lambda.yml",
        "iam":        "terraform-iam.yml",
        "vpc":        "terraform-vpc.yml",
        "cloudwatch": "terraform-cloudwatch.yml",
        "route53":    "terraform-route53.yml",
        "elb":        "terraform-elb.yml",
        "cloudfront": "terraform-cloudfront.yml",
        "codepipeline": "terraform-codepipeline.yml",
        "codebuild": "terraform-codebuild.yml",
        "codedeploy": "terraform-codedeploy.yml",
        "ssm": "terraform-ssm.yml",
        "budgets": "terraform-budgets.yml",
        "cost-explorer": "terraform-cost-explorer.yml",
        "trusted-advisor": "terraform-trusted-advisor.yml",
    }
    
    # Service colors pour l'UI
    SERVICE_COLORS = {
        "EC2":        "#f97316",  # Orange
        "S3":         "#22c55e",  # Green
        "RDS":        "#3b82f6",  # Blue
        "LAMBDA":     "#f59e0b",  # Amber
        "IAM":        "#ef4444",  # Red
        "VPC":        "#8b5cf6",  # Purple
        "CLOUDWATCH": "#ec4899",  # Pink
        "ROUTE53":    "#06b6d4",  # Cyan
        "ELB":        "#14b8a6",  # Teal
        "CLOUDFRONT": "#a855f7",  # Violet
        "CODEPIPELINE": "#3b82f6", # Blue
        "CODEBUILD": "#10b981",
        "CODEDEPLOY": "#8b5cf6",
        "SSM": "#06b6d4",
        "BUDGETS": "#eab308",  # Yellow/Amber
        "COSTEXPLORER": "#f97316",  # Orange
        "TRUSTEDADVISOR": "#22c55e",  # Green
    }
    
        # ---------------------------------------------------------------
    # CATALOGUE DES SERVICES — source unique de vérité
    # Jinja2 parcourt cette liste pour générer index.html
    # ---------------------------------------------------------------
    SERVICES = [
        # ── COMPUTE ────────────────────────────────────────────────
        {
            "slug":      "ec2",
            "name":      "EC2",
            "type":      "COMPUTE",
            "icon":      "🖥️",
            "color_1":   "#f97316",
            "color_2":   "#fb923c",
            "color_rgb": "249, 115, 22",
            "desc":      "Déployez des instances EC2 avec security groups, VPC par défaut, et configuration réseau complète.",
            "tags":      ["Auto-scaling", "SSH configuré", "Tags Terraform"],
        },
        {
            "slug":      "lambda",
            "name":      "Lambda",
            "type":      "SERVERLESS",
            "icon":      "⚡",
            "color_1":   "#f59e0b",
            "color_2":   "#fbbf24",
            "color_rgb": "245, 158, 11",
            "desc":      "Déployez des fonctions Lambda avec code ZIP, variables d'environnement, et triggers.",
            "tags":      ["Zero-ops", "Event-driven", "Logs CloudWatch"],
        },
        # ── STORAGE ────────────────────────────────────────────────
        {
            "slug":      "s3",
            "name":      "S3",
            "type":      "STORAGE",
            "icon":      "🪣",
            "color_1":   "#22c55e",
            "color_2":   "#4ade80",
            "color_rgb": "34, 197, 94",
            "desc":      "Créez des buckets S3 pour hébergement de sites statiques avec politique d'accès public et versioning.",
            "tags":      ["Static website", "Public access", "CORS"],
        },
        # ── DATABASE ───────────────────────────────────────────────
        {
            "slug":      "rds",
            "name":      "RDS",
            "type":      "DATABASE",
            "icon":      "🗄️",
            "color_1":   "#3b82f6",
            "color_2":   "#60a5fa",
            "color_rgb": "59, 130, 246",
            "desc":      "Provisionnez des bases de données relationnelles (MySQL, PostgreSQL, MariaDB) avec snapshots automatiques.",
            "tags":      ["Multi-AZ", "Backups auto", "Encryption"],
        },
        # ── SECURITY ───────────────────────────────────────────────
        {
            "slug":      "iam",
            "name":      "IAM",
            "type":      "SECURITY",
            "icon":      "🔐",
            "color_1":   "#ef4444",
            "color_2":   "#f87171",
            "color_rgb": "239, 68, 68",
            "desc":      "Créez des utilisateurs, groupes, rôles et politiques IAM avec principe du moindre privilège.",
            "tags":      ["Policies JSON", "MFA support", "Audit trails"],
        },
        {
            "slug":      "secrets-manager",
            "name":      "Secrets Manager",
            "type":      "SECURITY",
            "icon":      "🔑",
            "color_1":   "#dc2626",
            "color_2":   "#f87171",
            "color_rgb": "220, 38, 38",
            "desc":      "Stockez et gérez les secrets avec rotation automatique et chiffrement KMS.",
            "tags":      ["Rotation auto", "KMS", "Audit CloudTrail"],
        },
        # ── NETWORKING ─────────────────────────────────────────────
        {
            "slug":      "vpc",
            "name":      "VPC",
            "type":      "NETWORKING",
            "icon":      "🌐",
            "color_1":   "#8b5cf6",
            "color_2":   "#a78bfa",
            "color_rgb": "139, 92, 246",
            "desc":      "Configurez des VPC isolés avec subnets publics/privés, Internet Gateway, NAT Gateway et route tables.",
            "tags":      ["Subnets", "IGW/NAT", "Security Groups"],
        },
        {
            "slug":      "elb",
            "name":      "ELB",
            "type":      "LOAD BALANCING",
            "icon":      "⚖️",
            "color_1":   "#14b8a6",
            "color_2":   "#2dd4bf",
            "color_rgb": "20, 184, 166",
            "desc":      "Déployez des Application Load Balancers (ALB) ou Network Load Balancers (NLB) avec target groups.",
            "tags":      ["ALB/NLB", "SSL/TLS", "Health checks"],
        },
        {
            "slug":      "cloudfront",
            "name":      "CloudFront",
            "type":      "CDN",
            "icon":      "🚀",
            "color_1":   "#a855f7",
            "color_2":   "#c084fc",
            "color_rgb": "168, 85, 247",
            "desc":      "Créez des distributions CloudFront pour accélérer la livraison de contenu avec cache global et SSL.",
            "tags":      ["Edge locations", "HTTPS", "Custom domains"],
        },
        {
            "slug":      "route53",
            "name":      "Route 53",
            "type":      "DNS",
            "icon":      "🌍",
            "color_1":   "#06b6d4",
            "color_2":   "#22d3ee",
            "color_rgb": "6, 182, 212",
            "desc":      "Gérez des zones DNS, enregistrements A/CNAME/MX et le routage géographique.",
            "tags":      ["Health checks", "Geo routing", "Failover"],
        },
        # ── MONITORING ─────────────────────────────────────────────
        {
            "slug":      "cloudwatch",
            "name":      "CloudWatch",
            "type":      "MONITORING",
            "icon":      "📊",
            "color_1":   "#ec4899",
            "color_2":   "#f472b6",
            "color_rgb": "236, 72, 153",
            "desc":      "Configurez des alarmes, dashboards et log groups pour surveiller métriques, logs et événements AWS.",
            "tags":      ["Alarmes", "Dashboards", "Log insights"],
        },
        # ── DEVOPS ─────────────────────────────────────────────────
        {
            "slug":      "codepipeline",
            "name":      "CodePipeline",
            "type":      "DEVOPS",
            "icon":      "🔄",
            "color_1":   "#4051b5",
            "color_2":   "#6366f1",
            "color_rgb": "64, 81, 181",
            "desc":      "Automatisez vos pipelines CI/CD avec stages Source → Build → Test → Deploy et approbations manuelles.",
            "tags":      ["CI/CD", "Multi-stage", "Blue/Green"],
        },
        {
            "slug":      "codebuild",
            "name":      "CodeBuild",
            "type":      "DEVOPS",
            "icon":      "🔨",
            "color_1":   "#10b981",
            "color_2":   "#34d399",
            "color_rgb": "16, 185, 129",
            "desc":      "Compilez, testez et packagez votre code dans des environnements gérés avec buildspec personnalisé.",
            "tags":      ["Docker support", "Buildspec", "Cache S3"],
        },
        {
            "slug":      "codedeploy",
            "name":      "CodeDeploy",
            "type":      "DEVOPS",
            "icon":      "📦",
            "color_1":   "#8b5cf6",
            "color_2":   "#a78bfa",
            "color_rgb": "139, 92, 246",
            "desc":      "Déployez automatiquement sur EC2, Lambda ou ECS avec Blue/Green et rollback automatique.",
            "tags":      ["Blue/Green", "Rollback auto", "EC2/Lambda/ECS"],
        },
        # ── MANAGEMENT ─────────────────────────────────────────────
        {
            "slug":      "ssm",
            "name":      "Systems Manager",
            "type":      "MANAGEMENT",
            "icon":      "🛠️",
            "color_1":   "#06b6d4",
            "color_2":   "#22d3ee",
            "color_rgb": "6, 182, 212",
            "desc":      "Gérez vos paramètres de configuration via Parameter Store avec chiffrement KMS optionnel.",
            "tags":      ["Parameter Store", "Session Manager", "KMS"],
        },
        # ── COST ───────────────────────────────────────────────────
        {
            "slug":      "budgets",
            "name":      "Budgets",
            "type":      "COST",
            "icon":      "💰",
            "color_1":   "#eab308",
            "color_2":   "#facc15",
            "color_rgb": "234, 179, 8",
            "desc":      "Définissez des budgets AWS avec alertes par email ou SNS pour maîtriser vos coûts cloud.",
            "tags":      ["Alertes email", "SNS", "Seuils multiples"],
        },
        {
            "slug":      "cost-explorer",
            "name":      "Cost Explorer",
            "type":      "COST",
            "icon":      "📈",
            "color_1":   "#f97316",
            "color_2":   "#fb923c",
            "color_rgb": "249, 115, 22",
            "desc":      "Analysez et visualisez vos dépenses AWS avec rapports automatiques et prévisions.",
            "tags":      ["Rapports auto", "Prévisions", "Groupement"],
        },
        {
            "slug":      "trusted-advisor",
            "name":      "Trusted Advisor",
            "type":      "COST",
            "icon":      "🧭",
            "color_1":   "#22c55e",
            "color_2":   "#4ade80",
            "color_rgb": "34, 197, 94",
            "desc":      "Activez les vérifications automatiques de sécurité, performance, coût et limites de service AWS.",
            "tags":      ["Sécurité", "Performance", "Limites service"],
        },
    ]

class DevelopmentConfig(Config):
    """Configuration développement."""
    DEBUG = True
    ENV = 'development'

class ProductionConfig(Config):
    """Configuration production."""
    DEBUG = False
    ENV = 'production'

class TestingConfig(Config):
    """Configuration tests."""
    TESTING = True
    ENV = 'testing'

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}