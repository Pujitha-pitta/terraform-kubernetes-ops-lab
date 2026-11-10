variable "kube_context" {
  description = "Kubeconfig context for the local Docker Desktop Kubernetes cluster."
  type        = string
  default     = "docker-desktop"
}

variable "namespace" {
  description = "Dedicated namespace owned by this Terraform configuration."
  type        = string
  default     = "ops-demo-terraform"
}

variable "replicas" {
  description = "Number of application pods to keep running."
  type        = number
  default     = 3

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 3
    error_message = "For this local lab, replicas must be between 1 and 3."
  }
}

variable "image" {
  description = "The local image built by Docker Compose."
  type        = string
  default     = "ops-observability-demo:local"
}
