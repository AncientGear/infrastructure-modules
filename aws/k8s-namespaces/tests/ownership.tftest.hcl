mock_provider "kubernetes" {}

run "namespace_ownership" {
  command = plan

  variables {
    platform_namespace                = "gateway-system"
    authorized_application_namespaces = ["app-one", "app-two"]
  }

  assert {
    condition     = kubernetes_namespace_v1.platform.metadata[0].name == "gateway-system"
    error_message = "Platform namespace name changed."
  }

  assert {
    condition     = toset(keys(kubernetes_namespace_v1.authorized_application)) == toset(["app-one", "app-two"])
    error_message = "Application namespace owners differ from the input set."
  }

  assert {
    condition     = alltrue([for namespace in kubernetes_namespace_v1.authorized_application : namespace.metadata[0].labels["gateway.platform.deal-engine.io/authorized"] == "true"])
    error_message = "Application namespaces must retain the route authorization label."
  }

  assert {
    condition     = output.platform_namespace == "gateway-system" && toset(output.authorized_application_namespaces) == toset(["app-one", "app-two"])
    error_message = "Namespace outputs must reflect the owned names."
  }
}
