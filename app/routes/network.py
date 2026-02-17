"""Routes pour les services réseau (VPC, ELB, CloudFront, Route53)."""
from flask import Blueprint, render_template, request
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService

network_bp = Blueprint('network', __name__)

# ========== VPC ==========
@network_bp.route('/vpc')
def vpc_form():
    """Formulaire VPC — Virtual Private Cloud."""
    return render_template('form_vpc.html')

@network_bp.route('/vpc/trigger', methods=['POST'])
def trigger_vpc():
    """Déclenche le workflow Terraform VPC."""
    try:
        vpc_name   = request.form.get("vpc_name", "").strip()
        cidr_block = request.form.get("cidr_block", "10.0.0.0/16").strip()
        azs        = request.form.get("availability_zones", "2").strip()

        if not vpc_name:
            return ResponseService.error_response("Nom du VPC obligatoire", service="VPC")

        payload = {
            "ref": "main",
            "inputs": {
                "vpc_name":            vpc_name,
                "cidr_block":          cidr_block,
                "availability_zones":  azs,
            }
        }

        response = GitHubService.trigger_workflow("vpc", payload)
        
        if response.status_code == 204:
            return ResponseService.success_response(
                service="VPC",
                title="Virtual Private Cloud",
                details={
                    "Nom":   vpc_name,
                    "CIDR":  cidr_block,
                    "AZs":   f"{azs} zones",
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API ({response.status_code})", 
                response.text, 
                service="VPC"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="VPC")

# ========== ELB ==========
@network_bp.route('/elb')
def elb_form():
    """Formulaire ELB — Elastic Load Balancing."""
    return render_template('form_elb.html')

@network_bp.route('/elb/trigger', methods=['POST'])
def trigger_elb():
    """Déclenche le workflow Terraform ELB."""
    try:
        lb_name  = request.form.get("lb_name", "").strip()
        lb_type  = request.form.get("lb_type", "application").strip()
        tg_port  = request.form.get("target_group_port", "80").strip()

        if not lb_name:
            return ResponseService.error_response("Nom du Load Balancer obligatoire", service="ELB")

        payload = {
            "ref": "main",
            "inputs": {
                "lb_name":            lb_name,
                "lb_type":            lb_type,
                "target_group_port":  tg_port,
            }
        }

        response = GitHubService.trigger_workflow("elb", payload)
        
        if response.status_code == 204:
            return ResponseService.success_response(
                service="ELB",
                title="Elastic Load Balancer",
                details={
                    "Nom":   lb_name,
                    "Type":  lb_type.upper(),
                    "Port":  tg_port,
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API ({response.status_code})", 
                response.text, 
                service="ELB"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="ELB")

# ========== CLOUDFRONT ==========
@network_bp.route('/cloudfront')
def cloudfront_form():
    """Formulaire CloudFront — Content Delivery Network."""
    return render_template('form_cloudfront.html')

@network_bp.route('/cloudfront/trigger', methods=['POST'])
def trigger_cloudfront():
    """Déclenche le workflow Terraform CloudFront."""
    try:
        origin_domain = request.form.get("origin_domain", "").strip()
        comment       = request.form.get("distribution_comment", "").strip()
        price_class   = request.form.get("price_class", "PriceClass_100").strip()

        if not origin_domain:
            return ResponseService.error_response("Domaine d'origine obligatoire", service="CLOUDFRONT")

        payload = {
            "ref": "main",
            "inputs": {
                "origin_domain":         origin_domain,
                "distribution_comment":  comment,
                "price_class":           price_class,
            }
        }

        response = GitHubService.trigger_workflow("cloudfront", payload)
        
        if response.status_code == 204:
            return ResponseService.success_response(
                service="CLOUDFRONT",
                title="Distribution CloudFront",
                details={
                    "Origine":      origin_domain,
                    "Comment":      comment or "N/A",
                    "Price Class":  price_class,
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API ({response.status_code})", 
                response.text, 
                service="CLOUDFRONT"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="CLOUDFRONT")

# ========== ROUTE53 ==========
@network_bp.route('/route53')
def route53_form():
    """Formulaire Route 53 — DNS."""
    return render_template('form_route53.html')

@network_bp.route('/route53/trigger', methods=['POST'])
def trigger_route53():
    """Déclenche le workflow Terraform Route 53."""
    try:
        zone_name   = request.form.get("zone_name", "").strip()
        record_type = request.form.get("record_type", "A").strip()
        record_value = request.form.get("record_value", "").strip()

        if not all([zone_name, record_value]):
            return ResponseService.error_response("Champs obligatoires manquants", service="ROUTE53")

        payload = {
            "ref": "main",
            "inputs": {
                "zone_name":     zone_name,
                "record_type":   record_type,
                "record_value":  record_value,
            }
        }

        response = GitHubService.trigger_workflow("route53", payload)
        
        if response.status_code == 204:
            return ResponseService.success_response(
                service="ROUTE53",
                title="Zone DNS Route 53",
                details={
                    "Zone":    zone_name,
                    "Type":    record_type,
                    "Valeur":  record_value,
                }
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API ({response.status_code})", 
                response.text, 
                service="ROUTE53"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="ROUTE53")