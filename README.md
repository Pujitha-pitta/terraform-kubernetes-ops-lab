# AWS Cloud Infrastructure Deployment and Monitoring

**Project name:** Ops Observability Lab  
**Stack:** AWS · Docker · EKS · Kubernetes · Terraform · CloudWatch

A guided project for learning how to package a Python service, deploy it to Kubernetes, provision AWS infrastructure with Terraform, and monitor the cluster with CloudWatch.

## Learning sequence

1. **Python service and Docker** — run the API locally, inspect its health endpoints and structured logs.
2. **Kubernetes** — deploy two replicas, expose an in-cluster service, and observe probes, resource limits, and self-healing.
3. **Terraform and AWS** — learn providers, variables, modules, state, and plans, then review a plan for a VPC, EKS cluster, two managed nodes, ECR, CloudWatch logs, and a dashboard.
4. **Deploy and monitor** — push the image to ECR, deploy it to EKS, inspect logs and metrics, and investigate a simulated readiness or HTTP error.
5. **Cleanup and reflection** — destroy temporary cloud resources, confirm the cleanup, and write down what each layer contributes.

We will work through these phases one at a time. The AWS infrastructure is not created by simply opening the repository; Terraform must be deliberately applied.

## Start locally (no AWS charges)

Install Python 3.11+, Docker Desktop, and Git. From the project folder:

```powershell
docker compose up --build
```

Open `http://localhost:8000/` and try `/healthz`, `/readyz`, `/info`, and `/error`. In a second terminal, view the JSON request logs with:

```powershell
docker compose logs -f
```

Stop the local container with `Ctrl+C`, then run `docker compose down`.

## Kubernetes lab

For the local Kubernetes lesson, enable Kubernetes in Docker Desktop or install `kind` and `kubectl`. Build the image and load it into the local cluster before applying the manifests:

```powershell
docker build -t ops-observability-demo:local .
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml -f k8s/service.yaml
kubectl -n ops-demo get pods,service
kubectl -n ops-demo port-forward service/ops-demo 8000:80
```

For `kind`, load the image into the cluster with `kind load docker-image ops-observability-demo:local` after building it.

Use [`docs/troubleshooting.md`](docs/troubleshooting.md) as a command reference. The central learning habit is to inspect pod status, events, and logs before changing YAML.

## AWS cost and safety

**Do not run `terraform apply` until you have reviewed the plan and estimated the cost for your AWS account and region.** EKS has a cluster-hour charge, and this example also creates EC2 worker nodes, VPC networking including a NAT Gateway, ECR, CloudWatch logs/metrics, and a dashboard. The EKS control plane is currently listed at $0.10 per cluster-hour under standard support; NAT gateways have hourly and data-processing charges, and other resources are billed separately. Costs vary by region and usage. See [EKS pricing](https://aws.amazon.com/eks/pricing/), [AWS EKS FAQ](https://aws.amazon.com/eks/faqs/), [NAT Gateway pricing](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-pricing.html), and the [AWS Pricing Calculator](https://calculator.aws/).

This is a short-lived learning environment. Create resources only for a hands-on session, then run `terraform destroy` and check the AWS Billing console. A deleted cluster does not automatically remove every resource if it was created outside Terraform.

The cluster API endpoint is restricted to `admin_cidr`; set it to your current public IPv4 address with `/32` in `terraform.tfvars`. Never put AWS access keys in this repository. Use the AWS CLI profile / IAM Identity Center credentials and least privilege. The starter attaches CloudWatch permissions to the worker-node role for clarity; a later security lesson will replace that with a workload-scoped IAM role using IRSA or EKS Pod Identity.

## Terraform files

- `terraform/main.tf` — VPC, EKS managed node group, ECR repository, and CloudWatch dashboard.
- `terraform/variables.tf` — region, cluster version, node size, and restricted admin CIDR.
- `terraform/terraform.tfvars.example` — copy to `terraform.tfvars` and update your CIDR; the real file is ignored by Git.
- `k8s/` — namespace, deployment, and ClusterIP service.
- `app/main.py` — health/readiness endpoints, environment info, and structured request logs.

EKS requires subnets in multiple Availability Zones. The VPC module uses two private subnets and a single NAT Gateway to provide node egress with lower cost than one NAT Gateway per AZ; this is a learning tradeoff and not a production high-availability network design.

## Current learning checkpoint

Start with the local Docker lesson. The first concept is the difference between **liveness** (should Kubernetes restart a process?) and **readiness** (should Kubernetes send it traffic?). In this app, `/healthz` is liveness and `/readyz` is readiness.

### Lesson 1: run the service locally

1. Open PowerShell in this project folder.
2. Run `docker compose up --build` and wait for the image build to finish.
3. Open `http://localhost:8000/healthz` and `http://localhost:8000/info` in your browser.
4. In another PowerShell window, run `docker compose logs -f` and refresh one of those pages.
5. Stop the service with `Ctrl+C`, then run `docker compose down`.

What you should learn: Docker builds an image from the Dockerfile; Compose starts a container from that image; the health check asks the app if it is alive; and the app writes request logs to standard output so a platform can collect them. The next lesson is Kubernetes locally, before using any paid AWS resources.

## References

- [Amazon EKS Kubernetes version lifecycle](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- [Amazon EKS CloudWatch Observability add-on](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html)
- [EKS Container Insights metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-metrics-EKS.html)
- [Terraform AWS EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [Terraform AWS VPC module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Amazon EKS costs](https://aws.amazon.com/eks/pricing/)
