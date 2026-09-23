data "aws_caller_identity" "current" {}

locals {
  account_id              = coalesce(var.account_id, data.aws_caller_identity.current.account_id)
  oidc_provider_url       = trimprefix(var.oidc_provider_url, "https://")
  subject_service_account = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}