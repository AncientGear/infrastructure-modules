locals {
  aws_load_balancer_controller_chart_version      = "3.5.0"
  aws_load_balancer_controller_controller_version = "v3.5.0"
}

resource "helm_release" "aws_load_balancer_controller" {
  count = var.aws_load_balancer_controller.enabled ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = local.aws_load_balancer_controller_chart_version
  namespace  = var.aws_load_balancer_controller.namespace

  create_namespace  = false
  wait              = true
  timeout           = 600
  atomic            = true
  cleanup_on_fail   = true
  max_history       = 5
  dependency_update = false

  values = [yamlencode({
    clusterName                 = var.cluster_name
    region                      = var.region
    vpcId                       = var.vpc_id
    defaultTargetType           = "ip"
    defaultLoadBalancerScheme   = "internal"
    createIngressClassResource  = false
    enableWaf                   = false
    enableWafv2                 = false
    enableShield                = false
    enableServiceMutatorWebhook = false

    controllerConfig = {
      featureGates = {
        ALBGatewayAPI = true
        NLBGatewayAPI = false
      }
    }

    ingressClassParams = {
      create = false
    }

    image = merge(
      {
        tag = local.aws_load_balancer_controller_controller_version
      },
      var.aws_load_balancer_controller.image_repository == null ? {} : {
        repository = var.aws_load_balancer_controller.image_repository
      }
    )

    nodeSelector = var.aws_load_balancer_controller.node_selector
    tolerations  = var.aws_load_balancer_controller.tolerations

    serviceAccount = {
      create = true
      name   = var.aws_load_balancer_controller.service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = var.aws_load_balancer_controller.role_arn
      }
    }
  })]
}
