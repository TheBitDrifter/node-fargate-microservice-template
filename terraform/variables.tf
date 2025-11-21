variable "aws_region" {
  description = "The AWS region to deploy infrastructure into."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g., 'dev', 'staging', 'prod')"
  type        = string
}

variable "service_name" {
  description = "The unique base name for this microservice. Must be lowercase."
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository. Defaults to service_name if not provided."
  type        = string
  default     = null
}

variable "image_url" {
  description = "The ECR URL of the built Docker image. Supplied by the CI/CD pipeline."
  type        = string
}

variable "desired_count" {
  description = "The number of Fargate tasks to run (resilience setting)."
  type        = number
  default     = 2
}

# --- Network Defaults (Can be overridden but are stable) ---

variable "platform_state_bucket" {
  description = "The S3 bucket containing the shared platform state."
  type        = string
}



variable "listener_rule_priority" {
  description = "Priority for the ALB listener rule. Leave null to auto-assign."
  type        = number
  default     = null
}

