locals {
  app_labels = {
    "app.kubernetes.io/name"       = "ops-demo"
    "app.kubernetes.io/managed-by" = "terraform"
  }
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = "ops-demo"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels    = local.app_labels
  }

  spec {
    replicas = tostring(var.replicas)

    selector {
      match_labels = local.app_labels
    }

    template {
      metadata {
        labels = local.app_labels
      }

      spec {
        automount_service_account_token = false

        security_context {
          run_as_non_root = true
          run_as_user     = 10001
          run_as_group    = 10001

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name              = "ops-demo"
          image             = var.image
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 8000
            protocol       = "TCP"
          }

          env {
            name  = "APP_ENV"
            value = "terraform-local-kubernetes"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "96Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "192Mi"
            }
          }

          startup_probe {
            http_get {
              path = "/healthz"
              port = 8000
            }
            period_seconds    = 2
            failure_threshold = 15
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8000
            }
            period_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/readyz"
              port = 8000
            }
            period_seconds = 5
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true

            capabilities {
              drop = ["ALL"]
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name      = "ops-demo"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels    = local.app_labels
  }

  spec {
    type     = "ClusterIP"
    selector = local.app_labels

    port {
      name        = "http"
      port        = 80
      target_port = 8000
      protocol    = "TCP"
    }
  }
}
