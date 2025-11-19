output "service_url" {
  description = "The public API endpoint for this service"
  value       = module.service.service_url
}

output "ecr_repository_url" {
  description = "The ECR repository URL for this service"
  value       = module.service.ecr_repository_url
}
