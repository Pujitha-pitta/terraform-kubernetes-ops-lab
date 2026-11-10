data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = var.project_name
  cidr = "10.42.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.42.1.0/24", "10.42.2.0/24"]
  public_subnets  = ["10.42.101.0/24", "10.42.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true
  enable_irsa                               = true
  endpoint_private_access                   = true
  endpoint_public_access                    = true
  endpoint_public_access_cidrs               = [var.admin_cidr]
  enabled_log_types                         = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  create_cloudwatch_log_group               = true
  cloudwatch_log_group_retention_in_days     = 7

  addons = {
    coredns                    = { most_recent = true }
    eks-pod-identity-agent     = { most_recent = true }
    kube-proxy                 = { most_recent = true }
    vpc-cni                    = { most_recent = true }
    amazon-cloudwatch-observability = { most_recent = true }
  }

  eks_managed_node_groups = {
    learning = {
      name           = "learning"
      instance_types = [var.node_instance_type]
      min_size       = 2
      max_size       = 2
      desired_size   = 2

      # Beginner setup following AWS's worker-node permissions path.
      # Later lesson: replace these node-wide permissions with IRSA / Pod Identity.
      iam_role_additional_policies = {
        CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
        AWSXrayWriteOnlyAccess      = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
      }
    }
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}/ops-demo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_dashboard" "cluster" {
  dashboard_name = "${var.project_name}-overview"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6,
        properties = {
          view = "timeSeries", stacked = false, region = var.aws_region,
          title = "EKS node CPU utilization",
          metrics = [["ContainerInsights", "node_cpu_utilization", "ClusterName", var.cluster_name]]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6,
        properties = {
          view = "timeSeries", stacked = false, region = var.aws_region,
          title = "EKS node memory utilization",
          metrics = [["ContainerInsights", "node_memory_utilization", "ClusterName", var.cluster_name]]
        }
      },
      {
        type = "metric", x = 0, y = 6, width = 12, height = 6,
        properties = {
          view = "timeSeries", stacked = false, region = var.aws_region,
          title = "Running worker nodes",
          metrics = [["ContainerInsights", "cluster_node_count", "ClusterName", var.cluster_name]]
        }
      },
      {
        type = "metric", x = 12, y = 6, width = 12, height = 6,
        properties = {
          view = "timeSeries", stacked = false, region = var.aws_region,
          title = "Failed worker nodes",
          metrics = [["ContainerInsights", "cluster_failed_node_count", "ClusterName", var.cluster_name]]
        }
      }
    ]
  })
}
