# Internal EKS Gateway

This module creates one shared, internal HTTPS Gateway for an existing EKS cluster. Terraform owns the platform and authorized application namespaces plus Gateway API configuration; Argo CD owns application `Service` and `HTTPRoute` resources inside the authorized namespaces.

## Quick path

1. Bootstrap Gateway API standard CRDs `v1.6.0` and AWS Load Balancer Controller Gateway CRDs `v3.5.0` outside Terraform.
2. Install AWS Load Balancer Controller `3.5.0` with ALB Gateway API enabled, NLB disabled, IP targets by default, and an internal scheme.
3. Configure the root or Terragrunt unit's Kubernetes provider, then supply this module with the regional ACM certificate ARN and two or more explicit private subnet IDs.
4. Apply this module. Wait for AWS Load Balancer Controller to reconcile the ALB before configuring a future CloudFront VPC Origin.

## Ownership and boundary

| Area | Owner | Decision |
| --- | --- | --- |
| Gateway API and AWS LBC CRDs | External bootstrap | Prerequisite; not stored in this module's state. |
| AWS Load Balancer Controller | `aws/k8s-addons` | Prerequisite; this module does not install Helm releases. |
| Platform Gateway namespace, GatewayClass, LoadBalancerConfiguration, Gateway | Terraform | One shared ingress entry point per cluster/environment. |
| Authorized application namespaces | Terraform | Created and labelled for route attachment. |
| Application `Service` and `HTTPRoute` | Argo CD | Intentionally outside this module. |

The child module declares the Kubernetes provider requirement only. Provider authentication and configuration belong in the calling root/Terragrunt unit.

## Route authorization

Only `HTTPRoute` attachments are allowed, and only from namespaces matching the module-owned label selector exposed as `route_authorization_label`:

```text
gateway.platform.deal-engine.io/authorized=true
```

Argo CD may manage resources inside an authorized namespace, but it must not remove or alter that namespace label. This module creates no `HTTPRoute` or `Service`.

## Inputs

| Name | Required | Description |
| --- | --- | --- |
| `platform_namespace` | No | Gateway namespace; defaults to `gateway-system`. |
| `gateway_class_name` | Yes | Name for the ALB GatewayClass. |
| `gateway_name` | Yes | Name for the internal Gateway. |
| `load_balancer_configuration_name` | Yes | Name for the LoadBalancerConfiguration. |
| `hostname` | Yes | HTTPS listener hostname. Wildcard DNS names are accepted. |
| `regional_acm_certificate_arn` | Yes | Regional ACM certificate ARN for HTTPS:443. |
| `private_subnet_ids` | Yes | At least two distinct, explicit private subnet IDs. |
| `authorized_application_namespaces` | Yes | Non-empty set of Terraform-managed application namespaces. |
| `alb_tags` | No | Additional tags passed to AWS Load Balancer Controller. |

All names, hostnames, certificate ARNs, and subnet IDs are validated. The platform namespace cannot be included in the authorized application namespace set.

## Outputs

| Name | Purpose |
| --- | --- |
| `platform_namespace` | Namespace containing the platform Gateway resources. |
| `authorized_application_namespaces` | Namespaces Terraform created for applications. |
| `route_authorization_label` | Required namespace label selector for HTTPRoute attachment. |
| `gateway_class_name` | ALB GatewayClass identifier. |
| `gateway_name` | Gateway identifier. |
| `load_balancer_configuration_name` | LoadBalancerConfiguration identifier. |

This module does **not** output an ALB ARN. AWS Load Balancer Controller creates the ALB asynchronously, so CloudFront requires a later discovery or state-bridge step after reconciliation.

## Internal HTTPS ALB behavior

The Gateway declares an HTTPS listener on port 443 without a `tls` block. `LoadBalancerConfiguration` explicitly requests an `internal`, IPv4 ALB in the supplied private subnets and supplies the regional ACM certificate ARN as the default certificate for `HTTPS:443`. AWS Load Balancer Controller uses this `defaultCertificate` configuration; the Gateway does not use `certificateRefs` or placeholder TLS options. The Gateway exposes no HTTP listener and accepts only `HTTPRoute` attachments; it does not create NLB resources.

## Apply order and reconciliation

The Kubernetes API server must already recognize the custom resources during Terraform planning. Apply external CRD bootstrap first, then the AWS Load Balancer Controller addon, then this module. Terraform creates the namespaces and manifests, while AWS Load Balancer Controller reconciles the ALB asynchronously. A successful Terraform apply is therefore not evidence that the ALB is ready or that CloudFront can reach it.

## Lifecycle and destruction risk

Both the platform namespace and every authorized application namespace use `prevent_destroy`. Removing an application namespace from the input set, or attempting to destroy the module normally, stops with a lifecycle error rather than deleting a namespace that can contain Argo CD-managed resources.

This guard is not absolute: removing the entire module call/configuration can remove the lifecycle guard; removing resources from Terraform state, deleting the module state, manually changing state, or intentionally removing the lifecycle rule can also bypass it. Coordinate namespace cleanup with application owners and remove application resources before an explicit, reviewed destruction procedure.

## Non-goals

- Installing CRDs, AWS Load Balancer Controller, or any Helm release.
- Creating `HTTPRoute`, `Service`, NLB, CloudFront, VPC Origin, or AWS resources directly.
- Discovering subnets implicitly or fabricating the asynchronously created ALB ARN.
- Configuring the Kubernetes provider in this reusable child module.

## Local verification

Run from this module directory:

```bash
terraform fmt -check
terraform init -backend=false -input=false -no-color
terraform validate -no-color
```

Then, from the repository root:

```bash
git diff --check -- aws/k8s-gateway
```
