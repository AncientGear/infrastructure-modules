locals {
  route_authorization_label = {
    "gateway.platform.deal-engine.io/authorized" = "true"
  }
}

resource "kubernetes_manifest" "gateway_class" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = var.gateway_class_name
    }
    spec = {
      controllerName = "gateway.k8s.aws/alb"
    }
  }
}

resource "kubernetes_manifest" "load_balancer_configuration" {
  manifest = {
    apiVersion = "gateway.k8s.aws/v1"
    kind       = "LoadBalancerConfiguration"
    metadata = {
      name      = var.load_balancer_configuration_name
      namespace = var.platform_namespace
    }
    spec = {
      scheme        = "internal"
      ipAddressType = "ipv4"
      loadBalancerSubnets = [
        for subnet_id in var.private_subnet_ids : {
          identifier = subnet_id
        }
      ]
      tags = var.alb_tags
      listenerConfigurations = [
        {
          protocolPort       = "HTTPS:443"
          defaultCertificate = var.regional_acm_certificate_arn
        }
      ]
    }
  }

}

resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = var.gateway_name
      namespace = var.platform_namespace
    }
    spec = {
      gatewayClassName = var.gateway_class_name
      infrastructure = {
        parametersRef = {
          group = "gateway.k8s.aws"
          kind  = "LoadBalancerConfiguration"
          name  = var.load_balancer_configuration_name
        }
      }
      listeners = [
        {
          name     = "https"
          protocol = "HTTPS"
          port     = 443
          hostname = var.hostname
          allowedRoutes = {
            kinds = [
              {
                group = "gateway.networking.k8s.io"
                kind  = "HTTPRoute"
              }
            ]
            namespaces = {
              from = "Selector"
              selector = {
                matchLabels = local.route_authorization_label
              }
            }
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.gateway_class,
    kubernetes_manifest.load_balancer_configuration,
  ]
}
