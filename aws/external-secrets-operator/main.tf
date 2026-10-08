
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "2.11.0"
  namespace        = "external-secrets"
  create_namespace = true
  atomic           = true
  wait             = true
  timeout          = 600

  values = [yamlencode({
    # This release owns CRD installation and upgrades; do not install via Argo.
    # Published 2.11.0 CRDs serve/store external-secrets.io/v1 for T2.
    # Default ghcr.io/external-secrets/external-secrets:v2.11.0 has linux/arm64.
    installCRDs = true
    global = {
      # Verified in the published 2.11.0 chart for all three deployments.
      nodeSelector = {
        "kubernetes.io/arch" = "arm64"
        workload             = "shared"
      }
      tolerations = [{
        key      = "workload"
        operator = "Equal"
        value    = "shared"
        effect   = "NoSchedule"
      }]
    }

    resources = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
      limits = {
        memory = "256Mi"
      }
    }
    webhook = {
      create = true
      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          memory = "128Mi"
        }
      }
    }

    certController = {
      create = true
      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          memory = "128Mi"
        }
      }
    }
  })]
}
