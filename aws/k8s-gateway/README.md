# Internal EKS Gateway

This module creates one shared, internal HTTPS Gateway for an existing EKS cluster. The separate `aws/k8s-namespaces` module owns the platform and authorized application namespaces; this module owns Gateway API configuration, while Argo CD owns application `Service` and `HTTPRoute` resources inside the authorized namespaces.

## Quick path

1. Bootstrap Gateway API standard CRDs `v1.6.0` and AWS Load Balancer Controller Gateway CRDs `v3.5.0` outside Terraform.
2. Install AWS Load Balancer Controller `3.5.0` with ALB Gateway API enabled, NLB disabled, IP targets by default, and an internal scheme.
3. Configure the root or Terragrunt unit's Kubernetes provider, then supply this module with the regional ACM certificate ARN and two or more explicit private subnet IDs.
4. After the namespace unit owns the existing namespaces, apply this module. Wait for AWS Load Balancer Controller to reconcile the ALB before configuring a future CloudFront VPC Origin.

## Ownership and boundary

| Area | Owner | Decision |
| --- | --- | --- |
| Gateway API and AWS LBC CRDs | External bootstrap | Prerequisite; not stored in this module's state. |
| AWS Load Balancer Controller | `aws/k8s-addons` | Prerequisite; this module does not install Helm releases. |
| Platform Gateway namespace and authorized application namespaces | `aws/k8s-namespaces` | Owns existing namespace objects and the application route-authorization labels. |
| GatewayClass, LoadBalancerConfiguration, Gateway | This module | One shared ingress entry point per cluster/environment. |
| Application `Service` and `HTTPRoute` | Argo CD | Intentionally outside this module. |

The child module declares the Kubernetes provider requirement only. Provider authentication and configuration belong in the calling root/Terragrunt unit.

## Route authorization

Only `HTTPRoute` attachments are allowed, and only from namespaces matching the namespace-unit-owned label selector exposed as `route_authorization_label`:

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
| `authorized_application_namespaces` | Yes | Non-empty set of existing application namespaces owned by the namespace unit. |
| `alb_tags` | No | Additional tags passed to AWS Load Balancer Controller. |

All names, hostnames, certificate ARNs, and subnet IDs are validated. The platform namespace cannot be included in the authorized application namespace set.

## Outputs

| Name | Purpose |
| --- | --- |
| `platform_namespace` | Namespace containing the platform Gateway resources. |
| `authorized_application_namespaces` | Names of application namespaces authorized for routes (not owned here). |
| `route_authorization_label` | Required namespace label selector for HTTPRoute attachment. |
| `gateway_class_name` | ALB GatewayClass identifier. |
| `gateway_name` | Gateway identifier. |
| `load_balancer_configuration_name` | LoadBalancerConfiguration identifier. |

This module does **not** output an ALB ARN. AWS Load Balancer Controller creates the ALB asynchronously, so CloudFront requires a later discovery or state-bridge step after reconciliation.

## Internal HTTPS ALB behavior

The Gateway declares an HTTPS listener on port 443 without a `tls` block. `LoadBalancerConfiguration` explicitly requests an `internal`, IPv4 ALB in the supplied private subnets and supplies the regional ACM certificate ARN as the default certificate for `HTTPS:443`. AWS Load Balancer Controller uses this `defaultCertificate` configuration; the Gateway does not use `certificateRefs` or placeholder TLS options. The Gateway exposes no HTTP listener and accepts only `HTTPRoute` attachments; it does not create NLB resources.

## Apply order and reconciliation

The Kubernetes API server must already recognize the custom resources during Terraform planning. Apply external CRD bootstrap first, then the AWS Load Balancer Controller addon, then this module. The separate namespace unit owns namespaces; this module creates manifests, while AWS Load Balancer Controller reconciles the ALB asynchronously. A successful Terraform apply is therefore not evidence that the ALB is ready or that CloudFront can reach it.

## Lifecycle and destruction risk

Namespace destruction protection belongs in orchestration, not Terraform. A direct destroy of the namespace unit can delete namespaces and their contents; destroying EKS deletes everything in the cluster. Obtain explicit namespace deletion consent and coordinate with application owners before any teardown. Gateway no longer owns or protects namespaces.

## BREAKING: manual state migration

This module previously owned namespace resources. Upgrading Gateway configuration before transferring ownership can plan namespace deletion. Schedule a maintenance window, back up **both** unit states, and prohibit applies while ownership is in transition. Verify the actual names, cluster context, provider identity, and addresses in `terraform state list` and `terraform state show` for the *current calling root*; never infer names from defaults. Existing namespaces must be imported, not recreated.

1. Record the old Gateway root's namespace addresses from `terraform state list`. For a root calling the module as `gateway`, expected shapes are `module.gateway.kubernetes_namespace_v1.platform` and `module.gateway.kubernetes_namespace_v1.authorized_application["<verified-name>"]`. Root names and actual instance keys may differ; use only confirmed exact addresses. Back up both states before writes.
2. Prepare the new namespace root with inputs matching the observed cluster namespaces and their current authorization labels. Import the existing platform namespace into `module.<confirmed-namespace-module-name>.kubernetes_namespace_v1.platform` and each existing application namespace into `module.<confirmed-namespace-module-name>.kubernetes_namespace_v1.authorized_application["<verified-name>"]`; use the verified Kubernetes namespace name as the import ID. Confirm exact destination addresses from the new root's configuration and plan. Do not apply.
3. During the brief temporary dual-state ownership interval, perform **no applies**. Confirm imported objects and labels in the new state, then remove only the confirmed old Gateway namespace addresses using `terraform state rm` against the old root. This removes state ownership, not the Kubernetes objects. Never remove manifests or broad module addresses.
4. Confirm old state no longer contains namespace resources and new state contains each exactly once. Switch Gateway to this compatible version; inspect both plans with refresh enabled and require no namespace create/destroy/replacement or unexpected manifest change before any separately authorized apply. Do not replay or apply old Gateway configuration after handoff: it would attempt to own namespaces again. Keep the state backups until verification is complete.

No automatic migration script or live state mutation is provided here. Published live module references remain unchanged pending explicit release authorization.

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
