locals {
  route_authorization_label = {
    "gateway.platform.deal-engine.io/authorized" = "true"
  }
}

resource "kubernetes_namespace_v1" "platform" {
  metadata {
    name = var.platform_namespace
  }
}

resource "kubernetes_namespace_v1" "authorized_application" {
  for_each = var.authorized_application_namespaces

  metadata {
    name   = each.value
    labels = local.route_authorization_label
  }
}
