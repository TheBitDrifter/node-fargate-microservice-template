# This is the root configuration file for the Template Repository.

# --- TERRAFORM BACKEND CONFIGURATION ---
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # The backend is defined partially. The 'bucket' and 'dynamodb_table' names 
  # are omitted here and MUST be passed via '-backend-config' in the CI/CD pipeline.
  backend "s3" {
    # The 'key' is intentionally set to a static placeholder. 
    # The full dynamic path is calculated and injected via CLI.
    key     = "placeholder/state.tfstate"
    region  = "us-east-1"
    encrypt = true
    # Bucket name and DynamoDB table name are injected via CLI/secrets.
  }
}

# Define local variables for naming consistency
locals {
  # project_prefix was removed as it was only used by the platform module
}

# --- 1. READ SHARED PLATFORM STATE ---
# Instead of creating a new VPC, we read the state of the existing shared platform.
data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = var.platform_state_bucket
    key    = "platform/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

# --- 2. DEPLOY THE MICROSERVICE ---
# This module is provisioned ONCE per application (uses the 'service' module).
module "service" {
  source = "git::https://github.com/TheBitDrifter/terraform-aws-fargate-service.git?ref=main"
  # source = "../../terraform-aws-fargate-service"
  # source = "git::https://github.com/TheBitDrifter/terraform-aws-fargate-service.git?ref=main"
  # source = "../../terraform-aws-fargate-service"

  # SERVICE DETAILS 
  service_name   = var.service_name
  environment    = var.environment
  create_ecr     = var.environment == "staging"
  aws_region     = var.aws_region
  image_url      = var.image_url # CRITICAL: Injected by CI/CD
  container_port = 3000
  desired_count  = var.desired_count

  # AUTO SCALING
  min_capacity     = 1
  max_capacity     = 5
  cpu_threshold    = 70
  memory_threshold = 70

  # PLATFORM PLUG-IN (Consumes Outputs from the Shared Platform)
  vpc_id             = data.terraform_remote_state.platform.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.platform.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.platform.outputs.ecs_tasks_security_group_id]
  ecs_cluster_id     = data.terraform_remote_state.platform.outputs.ecs_cluster_id
  alb_listener_arn   = data.terraform_remote_state.platform.outputs.alb_listener_arn
  api_gateway_id     = data.terraform_remote_state.platform.outputs.api_gateway_id
  vpc_link_id        = data.terraform_remote_state.platform.outputs.vpc_link_id

  # ROUTING LOGIC
  path_pattern           = "/${var.service_name}/*"
  api_route_key          = "ANY /${var.service_name}/{proxy+}"
  listener_rule_priority = var.listener_rule_priority
}
