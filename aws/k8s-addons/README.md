# Kubernetes addons

This module installs optional EKS cluster addons. Its first redesigned release manages only the AWS Load Balancer Controller (AWS LBC).

## Ownership and prerequisites

The root Terraform module or Terragrunt live unit owns the Helm provider and cluster connection. This child module declares no provider configuration, Kubernetes provider, or kubeconfig path.

Before enabling AWS LBC:

1. Publish an IRSA role for the controller from the separate IRSA module.
2. Install Gateway API standard CRDs `v1.6.0` and AWS LBC Gateway CRDs `v3.5.0` through the external bootstrap workflow.
3. Configure the root Helm provider to reach the target cluster.

This module does not create the `kube-system` namespace.

## Pinned compatibility

| Component | Version | Ownership |
| --- | --- | --- |
| AWS LBC Helm chart | `eks/aws-load-balancer-controller` `3.5.0` | This module |
| AWS LBC controller | `v3.5.0` | Chart release |
| Gateway API CRDs | `v1.6.0` | External bootstrap |
| AWS LBC Gateway CRDs | `v3.5.0` | External bootstrap |

## Inputs

| Name | Required | Description |
| --- | --- | --- |
| `cluster_name` | Yes | EKS cluster name. |
| `region` | Yes | AWS region containing the cluster. |
| `vpc_id` | Yes | VPC ID containing the cluster. |
| `aws_load_balancer_controller` | No | Typed AWS LBC configuration; disabled by default. `role_arn` is required when enabled. |

```hcl
aws_load_balancer_controller = {
  enabled  = true
  role_arn = module.aws_load_balancer_controller_irsa.role_arn
}
```

`namespace` defaults to `kube-system` and `service_account_name` defaults to `aws-load-balancer-controller`.

## Output

`aws_load_balancer_controller` reports whether the addon is enabled and, when installed, its release name, namespace, and service account name. Disabled installations return null resource details.

## Helm behavior

The release uses an exact chart version, waits up to 600 seconds for readiness, is atomic, cleans up failed upgrades, and retains five release revisions. Helm creates and annotates its ServiceAccount with the supplied IRSA role ARN.

AWS LBC defaults to IP targets and internal load balancers. `controllerConfig.featureGates.ALBGatewayAPI` is enabled and `NLBGatewayAPI` is disabled. IngressClass and `ingressClassParams.create` are disabled, as are WAF, WAFv2, Shield, and the Service mutator webhook.

## Non-goals

- Gateway API CRD installation or Kubernetes CRD resources
- Kubernetes provider configuration or local bootstrap commands
- Cluster Autoscaler installation or IRSA management
- Gateway, load balancer, or live/Terragrunt configuration

## Verification

From this module directory, run:

```bash
terraform fmt -check
terraform init -backend=false -input=false -no-color
terraform validate -no-color
```
