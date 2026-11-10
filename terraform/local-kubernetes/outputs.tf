output "namespace" {
  description = "Dedicated Kubernetes namespace managed by Terraform."
  value       = kubernetes_namespace_v1.app.metadata[0].name
}

output "deployment" {
  description = "Deployment name managed by Terraform."
  value       = kubernetes_deployment_v1.app.metadata[0].name
}

output "service" {
  description = "Internal Kubernetes service name and type."
  value = {
    name = kubernetes_service_v1.app.metadata[0].name
    type = kubernetes_service_v1.app.spec[0].type
  }
}

output "replicas" {
  description = "Desired pod count."
  value       = var.replicas
}
