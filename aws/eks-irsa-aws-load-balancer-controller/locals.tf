locals {
  oidc_provider_url       = trimprefix(var.oidc_provider_url, "https://")
  subject_service_account = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}