"""Routes pour les services DevOps (CodePipeline, CodeBuild, CodeDeploy)."""
from flask import Blueprint, render_template, request
import re
from app.services.github_service import GitHubService
from app.services.response_service import ResponseService
from app.services.validation_service import ValidationService

devops_bp = Blueprint('devops', __name__)

# ========== CODEPIPELINE ==========
@devops_bp.route('/codepipeline')
def codepipeline_form():
    """Formulaire CodePipeline — CI/CD Pipeline."""
    return render_template('form_codepipeline.html')

@devops_bp.route('/trigger-codepipeline', methods=['POST'])
def trigger_codepipeline():
    """Déclenche le workflow Terraform CodePipeline."""
    try:
        # Récupération des champs de base
        pipeline_name = request.form.get("pipeline_name", "").strip()
        environment = request.form.get("environment", "").strip()
        region = request.form.get("region", "eu-west-3").strip()
        description = request.form.get("description", "").strip()

        # Configuration source
        source_provider = request.form.get("source_provider", "").strip()
        github_connection = request.form.get("github_connection", "").strip()
        repository = request.form.get("repository", "").strip()
        branch = request.form.get("branch", "main").strip()
        
        # CodeCommit
        codecommit_repository = request.form.get("codecommit_repository", "").strip()
        codecommit_branch = request.form.get("codecommit_branch", "main").strip()
        
        # S3
        s3_bucket = request.form.get("s3_bucket", "").strip()
        s3_object_key = request.form.get("s3_object_key", "").strip()

        # Configuration build
        enable_build = "true" if request.form.get("enable_build") else "false"
        build_project = request.form.get("build_project", "").strip()
        build_env = request.form.get("build_env", "ubuntu-standard-7.0").strip()
        build_compute = request.form.get("build_compute", "small").strip()
        buildspec = request.form.get("buildspec", "").strip()
        enable_build_cache = "true" if request.form.get("enable_build_cache") else "false"

        # Variables d'environnement (JSON string)
        build_env_vars = request.form.get("build_env_vars", "[]")

        # Configuration test
        enable_test = "true" if request.form.get("enable_test") else "false"
        test_project = request.form.get("test_project", "").strip()
        test_type = request.form.get("test_type", "integration").strip()

        # Configuration approbation
        manual_approval = "true" if request.form.get("manual_approval") else "false"
        approval_sns_topic = request.form.get("approval_sns_topic", "").strip()
        approvers = request.form.get("approvers", "").strip()

        # Configuration déploiement
        deploy_provider = request.form.get("deploy_provider", "").strip()
        
        # ECS
        ecs_cluster = request.form.get("ecs_cluster", "").strip()
        ecs_service = request.form.get("ecs_service", "").strip()
        ecs_image_definition_file = request.form.get("ecs_image_definition_file", "imagedefinitions.json").strip()
        
        # CodeDeploy
        codedeploy_application = request.form.get("codedeploy_application", "").strip()
        codedeploy_deployment_group = request.form.get("codedeploy_deployment_group", "").strip()
        
        # Lambda
        lambda_function_name = request.form.get("lambda_function_name", "").strip()
        
        # S3
        s3_deploy_bucket = request.form.get("s3_deploy_bucket", "").strip()
        s3_extract = "true" if request.form.get("s3_extract") else "false"

        # Notifications
        enable_notifications = "true" if request.form.get("enable_notifications") else "false"
        notification_sns_topic = request.form.get("notification_sns_topic", "").strip()
        enable_cloudwatch_alarms = "true" if request.form.get("enable_cloudwatch_alarms") else "false"

        # Tags et métadonnées
        tags = request.form.get("tags", "[]")
        owner = request.form.get("owner", "").strip()
        cost_center = request.form.get("cost_center", "").strip()

        # Validations de base
        if not all([pipeline_name, environment, source_provider, deploy_provider]):
            return ResponseService.error_response("Champs obligatoires manquants", service="CODEPIPELINE")

        if not re.match(r'^[a-zA-Z0-9_-]+$', pipeline_name):
            return ResponseService.error_response(f"Nom de pipeline invalide: '{pipeline_name}'", service="CODEPIPELINE")

        if environment not in ["dev", "staging", "prod"]:
            return ResponseService.error_response(f"Environnement invalide: '{environment}'", service="CODEPIPELINE")

        # Validation selon le provider source
        if source_provider in ["GitHub", "GitHubEnterprise", "Bitbucket"]:
            if not repository:
                return ResponseService.error_response("Repository obligatoire pour GitHub/Bitbucket", service="CODEPIPELINE")
        elif source_provider == "CodeCommit":
            if not codecommit_repository:
                return ResponseService.error_response("Nom du repository CodeCommit obligatoire", service="CODEPIPELINE")
        elif source_provider == "S3":
            if not s3_bucket or not s3_object_key:
                return ResponseService.error_response("Bucket et clé S3 obligatoires", service="CODEPIPELINE")

        # Validation selon le provider de déploiement
        if deploy_provider in ["ECS", "ECS-BlueGreen"]:
            if not ecs_cluster or not ecs_service:
                return ResponseService.error_response("Cluster et service ECS obligatoires", service="CODEPIPELINE")
        elif deploy_provider == "CodeDeploy":
            if not codedeploy_application or not codedeploy_deployment_group:
                return ResponseService.error_response("Application et deployment group CodeDeploy obligatoires", service="CODEPIPELINE")
        elif deploy_provider == "Lambda":
            if not lambda_function_name:
                return ResponseService.error_response("Nom de fonction Lambda obligatoire", service="CODEPIPELINE")
        elif deploy_provider == "S3":
            if not s3_deploy_bucket:
                return ResponseService.error_response("Bucket S3 de destination obligatoire", service="CODEPIPELINE")

        # Payload GitHub Actions
        payload = {
            "ref": "main",
            "inputs": {
                # Base
                "pipeline_name": pipeline_name,
                "environment": environment,
                "region": region,
                "description": description,
                
                # Source
                "source_provider": source_provider,
                "github_connection_arn": github_connection,
                "repository": repository,
                "branch": branch,
                "codecommit_repository_name": codecommit_repository,
                "codecommit_branch": codecommit_branch,
                "s3_source_bucket": s3_bucket,
                "s3_source_object_key": s3_object_key,
                
                # Build
                "enable_build": enable_build,
                "build_project_name": build_project,
                "build_environment": build_env,
                "build_compute_type": build_compute,
                "buildspec": buildspec,
                "build_env_vars": build_env_vars,
                "enable_build_cache": enable_build_cache,
                
                # Test
                "enable_test": enable_test,
                "test_project_name": test_project,
                "test_type": test_type,
                
                # Approval
                "manual_approval": manual_approval,
                "approval_sns_topic_arn": approval_sns_topic,
                "approvers": approvers,
                
                # Deploy
                "deploy_provider": deploy_provider,
                "ecs_cluster_name": ecs_cluster,
                "ecs_service_name": ecs_service,
                "ecs_image_definition_file": ecs_image_definition_file,
                "codedeploy_application_name": codedeploy_application,
                "codedeploy_deployment_group_name": codedeploy_deployment_group,
                "lambda_function_name": lambda_function_name,
                "s3_deploy_bucket": s3_deploy_bucket,
                "s3_extract_archive": s3_extract,
                
                # Notifications
                "enable_notifications": enable_notifications,
                "notification_sns_topic_arn": notification_sns_topic,
                "enable_cloudwatch_alarms": enable_cloudwatch_alarms,
                
                # Tags
                "tags": tags,
                "owner": owner,
                "cost_center": cost_center
            }
        }

        # Déclenchement du workflow
        response = GitHubService.trigger_workflow("codepipeline", payload)
        
        if response.status_code == 204:
            # Construire les détails selon la configuration
            details = {
                "Nom du pipeline": pipeline_name,
                "Environnement": environment,
                "Source": f"{source_provider} → {repository if repository else codecommit_repository if codecommit_repository else s3_bucket}",
                "Build": "Activé" if enable_build == "true" else "Désactivé",
            }
            
            if enable_test == "true":
                details["Tests"] = test_type.capitalize()
            
            if manual_approval == "true":
                details["Approbation"] = "Manuelle requise"
            
            details["Déploiement"] = deploy_provider
            
            if enable_notifications == "true":
                details["Notifications"] = "SNS activé"

            return ResponseService.success_response(
                service="CODEPIPELINE",
                title="Pipeline CI/CD",
                details=details
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API (Code: {response.status_code})",
                response.text,
                service="CODEPIPELINE"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="CODEPIPELINE")

# ========== CODEBUILD ==========
@devops_bp.route('/codebuild')
def codebuild_form():
    """Formulaire CodeBuild — Projet Build Serverless."""
    return render_template('form_codebuild.html')

@devops_bp.route('/trigger-codebuild', methods=['POST'])
def trigger_codebuild():
    """Déclenche le workflow Terraform CodeBuild."""
    try:
        # Récupération des champs de base
        project_name = request.form.get("project_name", "").strip()
        environment = request.form.get("environment", "").strip()
        region = request.form.get("region", "eu-west-3").strip()
        description = request.form.get("description", "").strip()

        # Configuration source
        source_type = request.form.get("source_type", "").strip()
        source_location = request.form.get("source_location", "").strip()
        source_version = request.form.get("source_version", "main").strip()

        # Configuration environnement
        environment_type = request.form.get("environment_type", "LINUX_CONTAINER").strip()
        image = request.form.get("image", "").strip()
        custom_image = request.form.get("custom_image", "").strip()
        compute_type = request.form.get("compute_type", "BUILD_GENERAL1_MEDIUM").strip()
        privileged_mode = "true" if request.form.get("privileged_mode") else "false"

        # Configuration buildspec
        buildspec_type = request.form.get("buildspec_type", "file").strip()
        buildspec = request.form.get("buildspec", "").strip()
        buildspec_path = request.form.get("buildspec_path", "buildspec.yml").strip()

        # Variables d'environnement (JSON string)
        environment_variables = request.form.get("environment_variables", "[]")

        # Configuration artifacts
        artifacts_type = request.form.get("artifacts_type", "NO_ARTIFACTS").strip()
        artifacts_bucket = request.form.get("artifacts_bucket", "").strip()
        artifacts_path = request.form.get("artifacts_path", "").strip()

        # Configuration cache
        enable_cache = "true" if request.form.get("enable_cache") else "false"
        cache_bucket = request.form.get("cache_bucket", "").strip()
        cache_paths = request.form.get("cache_paths", "").strip()

        # Configuration logs
        cloudwatch_logs = "true" if request.form.get("cloudwatch_logs") else "false"
        s3_logs = "true" if request.form.get("s3_logs") else "false"

        # Timeouts
        timeout = request.form.get("timeout", "60").strip()
        queued_timeout = request.form.get("queued_timeout", "480").strip()

        # Validations de base
        if not all([project_name, environment, source_type]):
            return ResponseService.error_response("Champs obligatoires manquants", service="CODEBUILD")

        if not re.match(r'^[a-zA-Z0-9_-]+$', project_name):
            return ResponseService.error_response(f"Nom de projet invalide: '{project_name}'", service="CODEBUILD")

        if environment not in ["dev", "staging", "prod"]:
            return ResponseService.error_response(f"Environnement invalide: '{environment}'", service="CODEBUILD")

        # Validation selon le type de source
        if source_type not in ["NO_SOURCE", "CODEPIPELINE"] and not source_location:
            return ResponseService.error_response(f"Emplacement source obligatoire pour le type '{source_type}'", service="CODEBUILD")

        # Validation artifacts S3
        if artifacts_type == "S3" and not artifacts_bucket:
            return ResponseService.error_response("Bucket S3 obligatoire pour les artifacts", service="CODEBUILD")

        # Validation cache S3
        if enable_cache == "true" and not cache_bucket:
            return ResponseService.error_response("Bucket S3 obligatoire pour le cache", service="CODEBUILD")

        # Déterminer l'image finale
        final_image = custom_image if image == "CUSTOM" else image

        # Payload GitHub Actions
        payload = {
            "ref": "main",
            "inputs": {
                # Base
                "project_name": project_name,
                "environment": environment,
                "region": region,
                "description": description,
                
                # Source
                "source_type": source_type,
                "source_location": source_location,
                "source_version": source_version,
                
                # Environnement
                "environment_type": environment_type,
                "image": final_image,
                "compute_type": compute_type,
                "privileged_mode": privileged_mode,
                
                # Buildspec
                "buildspec_type": buildspec_type,
                "buildspec": buildspec,
                "buildspec_path": buildspec_path,
                
                # Variables d'environnement
                "environment_variables": environment_variables,
                
                # Artifacts
                "artifacts_type": artifacts_type,
                "artifacts_bucket": artifacts_bucket,
                "artifacts_path": artifacts_path,
                
                # Cache
                "enable_cache": enable_cache,
                "cache_bucket": cache_bucket,
                "cache_paths": cache_paths,
                
                # Logs
                "cloudwatch_logs_enabled": cloudwatch_logs,
                "s3_logs_enabled": s3_logs,
                
                # Timeouts
                "timeout_minutes": timeout,
                "queued_timeout_minutes": queued_timeout
            }
        }

        # Déclenchement du workflow
        response = GitHubService.trigger_workflow("codebuild", payload)
        
        if response.status_code == 204:
            # Construire les détails
            details = {
                "Nom du projet": project_name,
                "Environnement": environment,
                "Source": f"{source_type}",
                "Image": final_image.split('/')[-1] if '/' in final_image else final_image,
                "Compute": compute_type.replace('BUILD_GENERAL1_', ''),
            }
            
            if privileged_mode == "true":
                details["Mode privilégié"] = "Activé (Docker)"
            
            if enable_cache == "true":
                details["Cache S3"] = "Activé"
            
            if artifacts_type != "NO_ARTIFACTS":
                details["Artifacts"] = artifacts_type

            return ResponseService.success_response(
                service="CODEBUILD",
                title="Projet Build",
                details=details
            )
        else:
            return ResponseService.error_response(
                f"Erreur GitHub API (Code: {response.status_code})",
                response.text,
                service="CODEBUILD"
            )

    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="CODEBUILD")

# ========== CODEDEPLOY ==========
@devops_bp.route('/codedeploy')
def codedeploy_form():
    """Formulaire CodeDeploy."""
    return render_template('form_codedeploy.html')

@devops_bp.route('/trigger-codedeploy', methods=['POST'])
def trigger_codedeploy():
    """Déclenche le workflow Terraform CodeDeploy."""
    try:
        application_name = request.form.get("application_name", "").strip()
        compute_platform = request.form.get("compute_platform", "").strip()
        deployment_group_name = request.form.get("deployment_group_name", "").strip()
        environment = request.form.get("environment", "").strip()
        region = request.form.get("region", "eu-west-3").strip()
        deployment_config = request.form.get("deployment_config", "").strip()

        # EC2
        ec2_tag_filters = request.form.get("ec2_tag_filters", "").strip()
        autoscaling_groups = request.form.get("autoscaling_groups", "").strip()

        # Lambda
        lambda_function_name = request.form.get("lambda_function_name", "").strip()
        lambda_alias = request.form.get("lambda_alias", "live").strip()

        # ECS
        ecs_cluster_name = request.form.get("ecs_cluster_name", "").strip()
        ecs_service_name = request.form.get("ecs_service_name", "").strip()

        # Blue/Green
        blue_green = "true" if request.form.get("blue_green_deployment") else "false"
        green_fleet_option = request.form.get("green_fleet_option", "").strip()
        terminate_blue = request.form.get("terminate_blue_instances", "").strip()
        bg_timeout = request.form.get("blue_green_timeout", "60").strip()

        # Rollback
        auto_rollback = "true" if request.form.get("auto_rollback") else "false"
        rollback_on_failure = "true" if request.form.get("rollback_on_failure") else "false"
        rollback_on_alarm = "true" if request.form.get("rollback_on_alarm") else "false"

        # Load Balancer
        use_lb = "true" if request.form.get("use_load_balancer") else "false"
        lb_type = request.form.get("load_balancer_type", "").strip()
        tg_name = request.form.get("target_group_name", "").strip()
        classic_lb = request.form.get("classic_lb_name", "").strip()

        if not all([application_name, compute_platform, deployment_group_name, environment]):
            return ResponseService.error_response("Champs obligatoires manquants", service="CODEDEPLOY")

        if not re.match(r'^[a-zA-Z0-9_-]+$', application_name):
            return ResponseService.error_response(f"Nom invalide: '{application_name}'", service="CODEDEPLOY")

        payload = {
            "ref": "main",
            "inputs": {
                "application_name": application_name,
                "compute_platform": compute_platform,
                "deployment_group_name": deployment_group_name,
                "environment": environment,
                "region": region,
                "deployment_config_name": deployment_config,
                "ec2_tag_filters": ec2_tag_filters,
                "autoscaling_groups": autoscaling_groups,
                "lambda_function_name": lambda_function_name,
                "lambda_alias": lambda_alias,
                "ecs_cluster_name": ecs_cluster_name,
                "ecs_service_name": ecs_service_name,
                "blue_green_enabled": blue_green,
                "green_fleet_option": green_fleet_option,
                "terminate_blue_instances": terminate_blue,
                "blue_green_timeout": bg_timeout,
                "auto_rollback_enabled": auto_rollback,
                "rollback_on_failure": rollback_on_failure,
                "rollback_on_alarm": rollback_on_alarm,
                "use_load_balancer": use_lb,
                "load_balancer_type": lb_type,
                "target_group_name": tg_name,
                "classic_lb_name": classic_lb
            }
        }

        response = GitHubService.trigger_workflow("codedeploy", payload)
        
        if response.status_code == 204:
            details = {
                "Application": application_name,
                "Plateforme": compute_platform,
                "Deployment Group": deployment_group_name,
                "Environnement": environment,
                "Stratégie": deployment_config.replace('CodeDeployDefault.', '')
            }
            
            if blue_green == "true":
                details["Mode"] = "Blue/Green"
            if auto_rollback == "true":
                details["Rollback"] = "Automatique"

            return ResponseService.success_response(service="CODEDEPLOY", title="Application", details=details)
        else:
            return ResponseService.error_response(f"Erreur GitHub API ({response.status_code})", response.text, service="CODEDEPLOY")
    except Exception as e:
        return ResponseService.error_response("Erreur inattendue", str(e), service="CODEDEPLOY")