# Troubleshooting field notes

Use these commands from PowerShell. Replace `ops-demo` or `ops-observability-lab` only if you changed the matching project name.

## Local Docker

```powershell
docker compose ps
docker compose logs --tail 100 ops-demo
docker compose down
```

If port 8000 is already in use, stop the other app using it, or change the left side of `8000:8000` in `compose.yaml` and open that new local port.

## Kubernetes

```powershell
kubectl -n ops-demo get deployment,pods,service -o wide
kubectl -n ops-demo describe pod <pod-name>
kubectl -n ops-demo logs deployment/ops-demo --all-pods=true --tail=100
kubectl -n ops-demo get events --sort-by=.metadata.creationTimestamp
kubectl -n ops-demo rollout status deployment/ops-demo
kubectl -n ops-demo port-forward service/ops-demo 8000:80
```

Interpret the evidence in this order:

1. **Pod phase / readiness:** `Pending` often points to scheduling or image-pull problems; `CrashLoopBackOff` means the process keeps exiting; `Running` with `0/1` ready often points to a failed readiness probe.
2. **Describe output and events:** look for `FailedScheduling`, `ErrImagePull`, `ImagePullBackOff`, probe failures, and resource-limit messages.
3. **Container logs:** check the application error before changing its Deployment.
4. **Service selectors and endpoints:** `kubectl -n ops-demo get service ops-demo -o yaml` and `kubectl -n ops-demo get endpoints ops-demo` help identify label mismatches or pods that are not ready.

For a safe readiness exercise, set `APP_READY` to `false` in the Deployment and apply it. Observe that the pod can remain alive while becoming unready and leaving the Service endpoints. Restore the value to `true` and apply again. This changes only the local learning cluster.

## AWS / EKS (only after the AWS lesson)

```powershell
aws sts get-caller-identity
aws eks update-kubeconfig --region ap-south-1 --name ops-observability-lab
kubectl get nodes
kubectl -n ops-demo get pods -o wide
kubectl -n ops-demo describe pod <pod-name>
kubectl -n ops-demo logs deployment/ops-demo --all-pods=true --tail=100
```

If the Kubernetes API is unreachable, first check the AWS CLI identity, cluster status, region, and whether your current public IP still matches `admin_cidr` in `terraform.tfvars`. Do not widen the endpoint to `0.0.0.0/0` as a troubleshooting shortcut.

Before applying Terraform or changing AWS resources, inspect the plan and costs. After the lab, run `terraform destroy` from the same Terraform directory and verify resources in the AWS console and billing tools.
