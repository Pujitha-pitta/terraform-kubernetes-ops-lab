output "cluster_name" {
  description = "EKS cluster name for kubectl configuration."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint. Access is restricted to admin_cidr."
  value       = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  description = "Push the built application image to this ECR repository."
  value       = aws_ecr_repository.app.repository_url
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard created by this project."
  value       = aws_cloudwatch_dashboard.cluster.dashboard_name
}

output "vpc_id" {
  description = "Learning VPC ID."
  value       = module.vpc.vpc_id
}
