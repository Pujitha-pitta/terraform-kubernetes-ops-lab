variable "aws_region" {
  description = "AWS region for this learning environment."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short name used for resource names and tags."
  type        = string
  default     = "ops-observability-lab"
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
  default     = "ops-observability-lab"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes minor version. Check regional support before deploying."
  type        = string
  default     = "1.36"
}

variable "admin_cidr" {
  description = "Your public IPv4 address in CIDR notation, usually x.x.x.x/32. Required to restrict the public EKS API endpoint."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr))
    error_message = "admin_cidr must be a valid IPv4 CIDR, such as 198.51.100.25/32."
  }
}

variable "node_instance_type" {
  description = "EC2 size for each learning node; review current regional pricing before deployment."
  type        = string
  default     = "t3.small"
}
