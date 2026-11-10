# Terraform Local Kubernetes Lab

This configuration uses Terraform to create a namespace, a two-replica app Deployment, and a ClusterIP Service in your local Docker Desktop Kubernetes cluster. It does not call AWS or create billable cloud resources.

## Before you begin

- Docker Desktop is running.
- Docker Desktop Kubernetes is active and kubectl get nodes shows docker-desktop as Ready.
- The image ops-observability-demo:local exists locally. Build it from the project root with docker compose build if needed.

## Learn the Terraform workflow

Open Command Prompt and enter this directory:

    cd /d "%USERPROFILE%\OneDrive\Documents\cloudwatch-eks-terraform-lab\terraform\local-kubernetes"

Initialize the directory. This downloads the Kubernetes provider; it does not create cluster resources:

    terraform init

Format and inspect the configuration:

    terraform fmt
    terraform validate

Create a proposed change plan:

    terraform plan

Read the plan. It should show one namespace, one Deployment, and one Service to be added, in the local docker-desktop cluster. To create them locally, run:

    terraform apply

Type yes when Terraform asks to confirm. This only updates your local Kubernetes cluster; it does not create AWS resources.

Check the result:

    kubectl get pods,service -n ops-demo-terraform

Access the app from another Command Prompt:

    kubectl port-forward service/ops-demo 8000:80 -n ops-demo-terraform

Open http://localhost:8000/healthz. Keep the port-forward window open while using the local app.

## Experiment with desired state

Change the replica count in variables.tf from 2 to 3, then run terraform plan and terraform apply again. Terraform updates the deployment; Kubernetes creates the additional pod. Return the value to 2 and apply again.

## Clean up

After the lesson, stop the port-forward with Ctrl+C and remove the Terraform-managed local resources:

    terraform destroy

Confirm with yes. Terraform removes only the resources tracked in this local configuration. The earlier ops-demo deployment in the separate ops-demo namespace remains untouched.

## What this demonstrates

- Terraform providers, variables, resources, state, plan, apply, and destroy.
- Kubernetes namespaces, Deployments, Services, probes, resource limits, and desired replica counts.
- Local IaC workflow without AWS usage or cloud charges.

The AWS EKS configuration in the parent terraform directory is a separate optional track. Applying it creates paid AWS resources; use it only after reviewing the current cost estimate.
