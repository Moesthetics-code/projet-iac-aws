"""
═══════════════════════════════════════════════════════════════════════════════
PROJET IAC SONATEL — AWS Management Console
Backend Flask unifié pour 10 services AWS avec Terraform + GitHub Actions
═══════════════════════════════════════════════════════════════════════════════
"""

from flask import Flask, request, render_template, redirect, url_for
import requests
import os
import json
import re
from dotenv import load_dotenv

# ── Charger les variables d'environnement ────────────────────────────────
load_dotenv()

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50 MB max upload

# ── Configuration GitHub ──────────────────────────────────────────────────
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
GITHUB_OWNER = os.getenv("GITHUB_OWNER", "Moesthetics-code")
GITHUB_REPO  = os.getenv("GITHUB_REPO",  "projet-iac-aws")

# Mapping des services vers leurs workflows GitHub Actions
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
}

# Couleurs par service pour les pages de succès/erreur
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
}


# ══════════════════════════════════════════════════════════════════════════
#  ROUTES — Pages de formulaires
# ══════════════════════════════════════════════════════════════════════════

@app.route("/")
def index():
    """Page d'accueil avec la grille des 10 services."""
    return render_template("index.html")


@app.route('/aide')
def aide():
    """Page d'aide et guide d'utilisation"""
    return render_template('aide.html')


@app.route("/ec2")
def ec2_form():
    """Formulaire EC2 — Elastic Compute Cloud."""
    return render_template("form_ec2.html")


@app.route("/s3")
def s3_form():
    """Formulaire S3 — Simple Storage Service."""
    return render_template("form_s3.html")


@app.route("/rds")
def rds_form():
    """Formulaire RDS — Relational Database Service."""
    return render_template("form_rds.html")


@app.route("/lambda")
def lambda_form():
    """Formulaire Lambda — Fonctions serverless."""
    return render_template("form_lambda.html")


@app.route("/iam")
def iam_form():
    """Formulaire IAM — Identity and Access Management."""
    return render_template("form_iam.html")


@app.route("/vpc")
def vpc_form():
    """Formulaire VPC — Virtual Private Cloud."""
    return render_template("form_vpc.html")


@app.route("/cloudwatch")
def cloudwatch_form():
    """Formulaire CloudWatch — Monitoring."""
    return render_template("form_cloudwatch.html")


@app.route("/route53")
def route53_form():
    """Formulaire Route 53 — DNS."""
    return render_template("form_route53.html")


@app.route("/elb")
def elb_form():
    """Formulaire ELB — Elastic Load Balancing."""
    return render_template("form_elb.html")


@app.route("/cloudfront")
def cloudfront_form():
    """Formulaire CloudFront — Content Delivery Network."""
    return render_template("form_cloudfront.html")


# ══════════════════════════════════════════════════════════════════════════
#  ROUTES — Déclenchement des pipelines Terraform
# ══════════════════════════════════════════════════════════════════════════

@app.route("/trigger-ec2", methods=["POST"])
def trigger_ec2():
    """Déclenche le workflow Terraform EC2."""
    try:
        # Récupération des champs
        instance_name = request.form.get("instance_name", "").strip()
        instance_os   = request.form.get("instance_os", "").strip()
        instance_size = request.form.get("instance_size", "").strip()
        instance_env  = request.form.get("instance_env", "").strip()

        # Validations
        if not all([instance_name, instance_os, instance_size, instance_env]):
            return error_response("Tous les champs sont obligatoires", service="EC2")

        if not re.match(r'^[a-zA-Z0-9_-]+$', instance_name):
            return error_response(f"Nom invalide: '{instance_name}'", service="EC2")

        if not instance_os.startswith("ami-"):
            return error_response(f"AMI invalide: '{instance_os}'", service="EC2")

        if instance_env not in ["dev", "preprod", "prod"]:
            return error_response(f"Environnement invalide: '{instance_env}'", service="EC2")

        # Payload GitHub Actions
        payload = {
            "ref": "main",
            "inputs": {
                "instance_name": instance_name,
                "instance_os":   instance_os,
                "instance_size": instance_size,
                "instance_env":  instance_env,
            }
        }

        # Déclenchement du workflow
        response = trigger_github_workflow("ec2", payload)
        
        if response.status_code == 204:
            return success_response(
                service="EC2",
                title="Instance EC2",
                details={
                    "Nom":          instance_name,
                    "AMI":          instance_os,
                    "Type":         instance_size,
                    "Environnement": instance_env,
                }
            )
        else:
            return error_response(
                f"Erreur GitHub API (Code: {response.status_code})",
                response.text,
                service="EC2"
            )

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="EC2")


@app.route("/trigger-s3", methods=["POST"])
def trigger_s3():
    """Déclenche le workflow Terraform S3."""
    try:
        bucket_name    = request.form.get("bucket_name", "").strip().lower()
        bucket_env     = request.form.get("bucket_env", "").strip()
        bucket_region  = request.form.get("bucket_region", "eu-west-3").strip()
        index_document = request.form.get("index_document", "index.html").strip()
        error_document = request.form.get("error_document", "error.html").strip()
        storage_class  = request.form.get("storage_class", "STANDARD").strip()
        enable_versioning = request.form.get("enable_versioning", "Disabled").strip()

        # Toggles
        block_public_acls       = "true" if request.form.get("block_public_acls") else "false"
        block_public_policy     = "true" if request.form.get("block_public_policy") else "false"
        ignore_public_acls      = "true" if request.form.get("ignore_public_acls") else "false"
        restrict_public_buckets = "true" if request.form.get("restrict_public_buckets") else "false"

        # Validations
        if not bucket_name or not bucket_env:
            return error_response("Champs obligatoires manquants", service="S3")

        if not re.match(r'^[a-z0-9][a-z0-9\-]{1,61}[a-z0-9]$', bucket_name):
            return error_response(f"Nom de bucket invalide: '{bucket_name}'", service="S3")

        if '--' in bucket_name:
            return error_response("Le nom du bucket ne peut pas contenir deux tirets consécutifs", service="S3")

        # Payload
        payload = {
            "ref": "main",
            "inputs": {
                "bucket_name":              bucket_name,
                "bucket_env":               bucket_env,
                "bucket_region":            bucket_region,
                "index_document":           index_document,
                "error_document":           error_document,
                "storage_class":            storage_class,
                "enable_versioning":        enable_versioning,
                "block_public_acls":        block_public_acls,
                "block_public_policy":      block_public_policy,
                "ignore_public_acls":       ignore_public_acls,
                "restrict_public_buckets":  restrict_public_buckets,
            }
        }

        response = trigger_github_workflow("s3", payload)
        
        if response.status_code == 204:
            website_url = f"https://{bucket_name}.s3-website.{bucket_region}.amazonaws.com"
            return success_response(
                service="S3",
                title="Bucket S3",
                details={
                    "Nom":     bucket_name,
                    "Région":  bucket_region,
                    "Env":     bucket_env,
                    "Storage": storage_class,
                    "URL":     website_url,
                }
            )
        else:
            return error_response(
                f"Erreur GitHub API (Code: {response.status_code})",
                response.text,
                service="S3"
            )

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="S3")


@app.route("/trigger-rds", methods=["POST"])
def trigger_rds():
    """Déclenche le workflow Terraform RDS."""
    try:
        db_identifier      = request.form.get("db_identifier", "").strip()
        engine             = request.form.get("engine", "").strip()
        engine_version     = request.form.get("engine_version", "").strip()
        instance_class     = request.form.get("instance_class", "").strip()
        allocated_storage  = request.form.get("allocated_storage", "20").strip()
        db_name            = request.form.get("db_name", "").strip()
        username           = request.form.get("username", "").strip()
        password           = request.form.get("password", "").strip()
        environment        = request.form.get("environment", "").strip()
        multi_az           = "true" if request.form.get("multi_az") else "false"
        backup_retention   = request.form.get("backup_retention", "7").strip()

        # Validations
        if not all([db_identifier, engine, engine_version, instance_class, username, password, environment]):
            return error_response("Champs obligatoires manquants", service="RDS")

        if not re.match(r'^[a-z][a-z0-9\-]*$', db_identifier):
            return error_response(f"DB Identifier invalide: '{db_identifier}'", service="RDS")

        if len(username) < 3 or len(username) > 16:
            return error_response("Username doit contenir entre 3 et 16 caractères", service="RDS")

        if len(password) < 8:
            return error_response("Le mot de passe doit contenir au moins 8 caractères", service="RDS")

        # Payload
        payload = {
            "ref": "main",
            "inputs": {
                "db_identifier":     db_identifier,
                "engine":            engine,
                "engine_version":    engine_version,
                "instance_class":    instance_class,
                "allocated_storage": allocated_storage,
                "db_name":           db_name,
                "username":          username,
                "password":          password,
                "environment":       environment,
                "multi_az":          multi_az,
                "backup_retention":  backup_retention,
            }
        }

        response = trigger_github_workflow("rds", payload)
        
        if response.status_code == 204:
            return success_response(
                service="RDS",
                title="Base de données RDS",
                details={
                    "Identifier":  db_identifier,
                    "Engine":      f"{engine} {engine_version}",
                    "Class":       instance_class,
                    "Storage":     f"{allocated_storage} GB",
                    "Multi-AZ":    "Oui" if multi_az == "true" else "Non",
                    "Env":         environment,
                }
            )
        else:
            return error_response(
                f"Erreur GitHub API (Code: {response.status_code})",
                response.text,
                service="RDS"
            )

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="RDS")


@app.route("/trigger-lambda", methods=["POST"])
def trigger_lambda():
    """Déclenche le workflow Terraform Lambda."""
    try:
        function_name = request.form.get("function_name", "").strip()
        runtime       = request.form.get("runtime", "").strip()
        handler       = request.form.get("handler", "").strip()
        memory_size   = request.form.get("memory_size", "128").strip()
        timeout       = request.form.get("timeout", "3").strip()
        environment   = request.form.get("environment", "").strip()

        if not all([function_name, runtime, handler, environment]):
            return error_response("Champs obligatoires manquants", service="LAMBDA")

        payload = {
            "ref": "main",
            "inputs": {
                "function_name": function_name,
                "runtime":       runtime,
                "handler":       handler,
                "memory_size":   memory_size,
                "timeout":       timeout,
                "environment":   environment,
            }
        }

        response = trigger_github_workflow("lambda", payload)
        
        if response.status_code == 204:
            return success_response(
                service="LAMBDA",
                title="Fonction Lambda",
                details={
                    "Nom":     function_name,
                    "Runtime": runtime,
                    "Memory":  f"{memory_size} MB",
                    "Timeout": f"{timeout}s",
                    "Env":     environment,
                }
            )
        else:
            return error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="LAMBDA")

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="LAMBDA")


@app.route("/trigger-iam", methods=["POST"])
def trigger_iam():
    """Déclenche le workflow Terraform IAM."""
    try:
        resource_type = request.form.get("resource_type", "").strip()
        resource_name = request.form.get("resource_name", "").strip()
        path          = request.form.get("path", "/").strip()

        if not all([resource_type, resource_name]):
            return error_response("Champs obligatoires manquants", service="IAM")

        payload = {
            "ref": "main",
            "inputs": {
                "resource_type": resource_type,
                "resource_name": resource_name,
                "path":          path,
            }
        }

        response = trigger_github_workflow("iam", payload)
        
        if response.status_code == 204:
            return success_response(
                service="IAM",
                title="Ressource IAM",
                details={
                    "Type": resource_type,
                    "Nom":  resource_name,
                    "Path": path,
                }
            )
        else:
            return error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="IAM")

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="IAM")


@app.route("/trigger-vpc", methods=["POST"])
def trigger_vpc():
    """Déclenche le workflow Terraform VPC."""
    try:
        vpc_name   = request.form.get("vpc_name", "").strip()
        cidr_block = request.form.get("cidr_block", "10.0.0.0/16").strip()
        azs        = request.form.get("availability_zones", "2").strip()

        if not vpc_name:
            return error_response("Nom du VPC obligatoire", service="VPC")

        payload = {
            "ref": "main",
            "inputs": {
                "vpc_name":            vpc_name,
                "cidr_block":          cidr_block,
                "availability_zones":  azs,
            }
        }

        response = trigger_github_workflow("vpc", payload)
        
        if response.status_code == 204:
            return success_response(
                service="VPC",
                title="Virtual Private Cloud",
                details={
                    "Nom":   vpc_name,
                    "CIDR":  cidr_block,
                    "AZs":   f"{azs} zones",
                }
            )
        else:
            return error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="VPC")

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="VPC")


@app.route("/trigger-cloudwatch", methods=["POST"])
def trigger_cloudwatch():
    """Déclenche le workflow Terraform CloudWatch."""
    try:
        alarm_name = request.form.get("alarm_name", "").strip()
        metric     = request.form.get("metric_name", "").strip()
        threshold  = request.form.get("threshold", "").strip()

        if not all([alarm_name, metric, threshold]):
            return error_response("Champs obligatoires manquants", service="CLOUDWATCH")

        payload = {
            "ref": "main",
            "inputs": {
                "alarm_name":   alarm_name,
                "metric_name":  metric,
                "threshold":    threshold,
            }
        }

        response = trigger_github_workflow("cloudwatch", payload)
        
        if response.status_code == 204:
            return success_response(
                service="CLOUDWATCH",
                title="Alarme CloudWatch",
                details={
                    "Nom":       alarm_name,
                    "Métrique":  metric,
                    "Seuil":     threshold,
                }
            )
        else:
            return error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="CLOUDWATCH")

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="CLOUDWATCH")


@app.route("/trigger-route53", methods=["POST"])
def trigger_route53():
    """Déclenche le workflow Terraform Route 53."""
    try:
        zone_name   = request.form.get("zone_name", "").strip()
        record_type = request.form.get("record_type", "A").strip()
        record_value = request.form.get("record_value", "").strip()

        if not all([zone_name, record_value]):
            return error_response("Champs obligatoires manquants", service="ROUTE53")

        payload = {
            "ref": "main",
            "inputs": {
                "zone_name":     zone_name,
                "record_type":   record_type,
                "record_value":  record_value,
            }
        }

        response = trigger_github_workflow("route53", payload)
        
        if response.status_code == 204:
            return success_response(
                service="ROUTE53",
                title="Zone DNS Route 53",
                details={
                    "Zone":    zone_name,
                    "Type":    record_type,
                    "Valeur":  record_value,
                }
            )
        else:
            return error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="ROUTE53")

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="ROUTE53")


@app.route("/trigger-elb", methods=["POST"])
def trigger_elb():
    """Déclenche le workflow Terraform ELB."""
    try:
        lb_name  = request.form.get("lb_name", "").strip()
        lb_type  = request.form.get("lb_type", "application").strip()
        tg_port  = request.form.get("target_group_port", "80").strip()

        if not lb_name:
            return error_response("Nom du Load Balancer obligatoire", service="ELB")

        payload = {
            "ref": "main",
            "inputs": {
                "lb_name":            lb_name,
                "lb_type":            lb_type,
                "target_group_port":  tg_port,
            }
        }

        response = trigger_github_workflow("elb", payload)
        
        if response.status_code == 204:
            return success_response(
                service="ELB",
                title="Elastic Load Balancer",
                details={
                    "Nom":   lb_name,
                    "Type":  lb_type.upper(),
                    "Port":  tg_port,
                }
            )
        else:
            return error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="ELB")

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="ELB")


@app.route("/trigger-cloudfront", methods=["POST"])
def trigger_cloudfront():
    """Déclenche le workflow Terraform CloudFront."""
    try:
        origin_domain = request.form.get("origin_domain", "").strip()
        comment       = request.form.get("distribution_comment", "").strip()
        price_class   = request.form.get("price_class", "PriceClass_100").strip()

        if not origin_domain:
            return error_response("Domaine d'origine obligatoire", service="CLOUDFRONT")

        payload = {
            "ref": "main",
            "inputs": {
                "origin_domain":         origin_domain,
                "distribution_comment":  comment,
                "price_class":           price_class,
            }
        }

        response = trigger_github_workflow("cloudfront", payload)
        
        if response.status_code == 204:
            return success_response(
                service="CLOUDFRONT",
                title="Distribution CloudFront",
                details={
                    "Origine":      origin_domain,
                    "Comment":      comment or "N/A",
                    "Price Class":  price_class,
                }
            )
        else:
            return error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="CLOUDFRONT")

    except Exception as e:
        return error_response("Erreur inattendue", str(e), service="CLOUDFRONT")


# ══════════════════════════════════════════════════════════════════════════
#  HELPERS
# ══════════════════════════════════════════════════════════════════════════

def trigger_github_workflow(service: str, payload: dict):
    """
    Déclenche un workflow GitHub Actions pour le service donné.
    
    Args:
        service: Nom du service (ec2, s3, rds...)
        payload: Payload JSON contenant les inputs du workflow
    
    Returns:
        requests.Response object
    """
    workflow_id = WORKFLOWS.get(service)
    if not workflow_id:
        raise ValueError(f"Workflow non trouvé pour le service: {service}")
    
    url = (
        f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}"
        f"/actions/workflows/{workflow_id}/dispatches"
    )
    
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "X-GitHub-Api-Version": "2022-11-28"
    }
    
    print("=" * 70)
    print(f"🚀 DÉCLENCHEMENT WORKFLOW {service.upper()}")
    print(f"URL      : {url}")
    print(f"Inputs   : {json.dumps(payload.get('inputs', {}), indent=2)}")
    print("=" * 70)
    
    response = requests.post(url, json=payload, headers=headers, timeout=10)
    
    print(f"Status   : {response.status_code}")
    if response.status_code != 204:
        print(f"Response : {response.text}")
    print("=" * 70)
    
    return response


def success_response(service: str, title: str, details: dict):
    """Génère une page de succès unifiée avec couleur par service."""
    details_html = "".join(
        f"""
        <div class="detail-cell">
            <div class="detail-label">{key}</div>
            <div class="detail-value">{value}</div>
        </div>
        """
        for key, value in details.items()
    )
    
    color = SERVICE_COLORS.get(service.upper(), "#0ea5e9")
    
    return f"""
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="UTF-8">
        <title>{service} — Déploiement déclenché</title>
        <link href="https://fonts.googleapis.com/css2?family=Space+Mono&family=Sora:wght@400;700;800&display=swap" rel="stylesheet">
        <style>
            *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
            body {{
                font-family: 'Sora', sans-serif;
                background: #060d1f;
                color: #f8fafc;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 40px 20px;
            }}
            .card {{
                background: rgba(10,22,40,0.95);
                border: 1px solid {color}40;
                border-radius: 20px;
                max-width: 640px;
                width: 100%;
                padding: 48px 40px;
                text-align: center;
                box-shadow: 0 0 60px {color}20;
            }}
            .icon {{ font-size: 72px; margin-bottom: 20px; display: block; }}
            h1 {{ font-size: 28px; font-weight: 800; color: {color}; margin-bottom: 8px; }}
            .subtitle {{ color: #94a3b8; font-size: 14px; margin-bottom: 32px; }}
            .detail-grid {{
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 12px;
                text-align: left;
                margin-bottom: 32px;
            }}
            .detail-cell {{
                background: rgba(15,32,68,0.7);
                border: 1px solid rgba(14,165,233,0.15);
                border-radius: 10px;
                padding: 14px 16px;
            }}
            .detail-label {{
                font-family: 'Space Mono', monospace;
                font-size: 10px;
                text-transform: uppercase;
                letter-spacing: 0.1em;
                color: #64748b;
                margin-bottom: 4px;
            }}
            .detail-value {{ font-size: 14px; font-weight: 600; color: #f8fafc; word-break: break-word; }}
            .btn {{
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 13px 28px;
                margin: 8px;
                border-radius: 10px;
                font-family: 'Sora', sans-serif;
                font-size: 14px;
                font-weight: 600;
                text-decoration: none;
                cursor: pointer;
                border: none;
                transition: all 0.2s;
            }}
            .btn-primary {{
                background: linear-gradient(135deg, {color}, {color}dd);
                color: #fff;
            }}
            .btn-secondary {{
                background: rgba(14,165,233,0.1);
                border: 1px solid rgba(14,165,233,0.3);
                color: #0ea5e9;
            }}
            .btn:hover {{ transform: translateY(-2px); }}
        </style>
    </head>
    <body>
        <div class="card">
            <span class="icon">✅</span>
            <h1>Pipeline déclenché avec succès !</h1>
            <p class="subtitle">{title} · Déploiement en cours via GitHub Actions</p>
            <div class="detail-grid">{details_html}</div>
            <div>
                <a href="https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/actions" class="btn btn-primary" target="_blank">
                    📊 Suivre le déploiement
                </a>
                <a href="/" class="btn btn-secondary">🏠 Accueil</a>
            </div>
        </div>
    </body>
    </html>
    """


def error_response(title: str, details: str = "", service: str = ""):
    """Génère une page d'erreur unifiée."""
    detail_block = (
        f'<div class="error-details"><strong>Détails:</strong><br>{details}</div>'
        if details else ""
    )
    
    return f"""
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="UTF-8">
        <title>Erreur — {service}</title>
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;700&display=swap" rel="stylesheet">
        <style>
            body {{
                font-family: 'Sora', sans-serif;
                background: #060d1f;
                color: #f8fafc;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 40px 20px;
            }}
            .card {{
                background: rgba(10,22,40,0.95);
                border: 1px solid rgba(239,68,68,0.3);
                border-radius: 20px;
                max-width: 580px;
                width: 100%;
                padding: 48px 40px;
                text-align: center;
                box-shadow: 0 0 60px rgba(239,68,68,0.08);
            }}
            .icon {{ font-size: 72px; margin-bottom: 20px; display: block; }}
            h1 {{ font-size: 26px; color: #ef4444; margin-bottom: 12px; }}
            p {{ color: #94a3b8; margin-bottom: 16px; }}
            .error-details {{
                background: rgba(239,68,68,0.1);
                border: 1px solid rgba(239,68,68,0.25);
                border-radius: 10px;
                padding: 14px 16px;
                text-align: left;
                font-size: 12px;
                color: #fca5a5;
                word-break: break-word;
                margin: 16px 0 24px;
            }}
            .btn {{
                display: inline-block;
                padding: 13px 28px;
                background: linear-gradient(135deg, #0ea5e9, #0284c7);
                color: #060d1f;
                border-radius: 10px;
                text-decoration: none;
                font-weight: 700;
                font-size: 14px;
                margin: 4px;
            }}
        </style>
    </head>
    <body>
        <div class="card">
            <span class="icon">❌</span>
            <h1>Erreur de déploiement</h1>
            <p><strong>{title}</strong></p>
            {detail_block}
            <a href="javascript:history.back()" class="btn">🔄 Réessayer</a>
            <a href="/" class="btn">🏠 Accueil</a>
        </div>
    </body>
    </html>
    """


# ══════════════════════════════════════════════════════════════════════════
#  ENTRYPOINT
# ══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("☁️  PROJET IAC SONATEL — AWS Management Console")
    print(f"📍 URL          : http://localhost:5000")
    print(f"👤 GitHub Owner : {GITHUB_OWNER}")
    print(f"📦 Repository   : {GITHUB_REPO}")
    print(f"🔑 Token        : {'configuré ✅' if GITHUB_TOKEN else 'MANQUANT ❌'}")
    print(f"🌐 Services     : {len(WORKFLOWS)} disponibles")
    print("=" * 70)
    print("\n🎯 Services opérationnels:")
    for service in WORKFLOWS.keys():
        print(f"   • {service.upper():12} → /trigger-{service}")
    print("\n" + "=" * 70)
    
    app.run(debug=True, host="0.0.0.0", port=5000)