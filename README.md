# Terraform Kubernetes Ops Lab

A local observability lab for learning Terraform and Kubernetes without creating paid AWS resources. It packages a small Python API in Docker, then manages a Kubernetes namespace, Deployment, and ClusterIP Service with Terraform.

## Stack

Python · Docker · Docker Desktop Kubernetes · Kubernetes · Terraform

## Prerequisites

- Docker Desktop with Kubernetes enabled
- `kubectl`
- Terraform

## Run the app with Docker Compose

From the repository root:

```cmd
docker compose up --build
```

Open `http://localhost:8000/healthz`, `http://localhost:8000/readyz`, and `http://localhost:8000/info`. Stop the app with `Ctrl+C`, then run `docker compose down`.

## Manage the Kubernetes deployment with Terraform

Build the local image from the repository root:

```cmd
docker build -t ops-observability-demo:local .
```

Then initialize and apply the Terraform configuration:

```cmd
cd terraform\local-kubernetes
terraform init
terraform validate
terraform plan
terraform apply
```

Type `yes` when Terraform asks to create the local namespace, Deployment, and Service. Check the deployment:

```cmd
kubectl -n ops-demo-terraform get pods,service
```

Access the service through a local port forward (keep this terminal open):

```cmd
kubectl port-forward -n ops-demo-terraform service/ops-demo 8001:80
```

Visit `http://localhost:8001/healthz`. If port 8001 is already in use, choose another local port such as `8002:80` and visit that port instead.

Change the replica count in `variables.tf`, then use `terraform plan` and `terraform apply` to observe the change. To remove the Terraform-managed local resources when finished:

```cmd
terraform destroy
```

Review the plan before applying or destroying resources. The steps above target the local Kubernetes context and do not provision AWS, EKS, or CloudWatch resources. The repository also retains a separate AWS EKS configuration under `terraform/`; applying it can create billable AWS resources.
