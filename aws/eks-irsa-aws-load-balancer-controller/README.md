# AWS Load Balancer Controller IRSA

This Terraform module creates the AWS IAM identity required by the AWS Load Balancer Controller (LBC) in one EKS cluster. It is intentionally limited to AWS IAM and IRSA; Kubernetes and GitOps resources are owned elsewhere. Its policy is tailored for the project's ALB/Gateway API L7 baseline rather than being a verbatim copy of the upstream policy.

## Architecture boundary

| Owner | Responsibilities |
|---|---|
| Terraform/Terragrunt | AWS, EKS, IAM/IRSA, AWS LBC Helm release, Gateway API and AWS LBC CRDs, GatewayClass, and platform-owned Gateways |
| This module | IAM role, custom IAM policy, policy attachment, and OIDC trust policy for the controller service account |
| Argo CD | Backend workloads and application-owned resources such as Service and HTTPRoute |

This module does not install Helm charts or Kubernetes resources. A separate Terraform platform-addons module must manage the AWS LBC release using the namespace and service-account name supplied here, and must annotate that service account with the exported role ARN. Argo CD remains responsible for deploying backend products, including their Services and HTTPRoutes.

## Trust flow

1. A pod using `system:serviceaccount:<namespace>:<service_account_name>` receives a projected EKS OIDC token.
2. AWS STS validates the token against the supplied EKS OIDC provider.
3. The role trust policy requires both that exact `sub` claim and the `sts.amazonaws.com` audience.
4. The controller assumes the role and receives the permissions in this module's custom policy.

## Resources created

- `aws_iam_role.this`
- `aws_iam_policy.aws_load_balancer_controller`
- `aws_iam_role_policy_attachment.this`

The IAM policy document is generated locally as a Terraform data source; it is not a separately managed AWS resource.

## Module contract

### Required inputs

| Input | Purpose |
|---|---|
| `cluster_name` | EKS cluster name used in controller resource-tag conditions |
| `vpc_id` | VPC ID used to constrain security-group rule management |
| `aws_region` | AWS region used to construct scoped resource ARNs |
| `account_id` | AWS account ID used to construct scoped resource ARNs |
| `oidc_provider_arn` | ARN of the EKS IAM OIDC provider |
| `oidc_provider_url` | HTTPS EKS OIDC issuer URL; validated as an EKS issuer URL |
| `role_name` | Name for the IAM role |

Optional inputs are `namespace` (`kube-system`), `service_account_name` (`aws-load-balancer-controller`), `tags` (empty map), and `aws_load_balancer_controller_policy_name` (`AWSLoadBalancerControllerIAMPolicy`).

### Outputs

| Output | Use |
|---|---|
| `role_arn` | Service-account IRSA annotation value |
| `role_name` | IAM role identifier |
| `policy_arn` | Custom policy identifier for audit and review |
| `namespace` | Expected controller namespace |
| `service_account_name` | Expected controller service-account name |

## Usage contract

Provide values from the EKS and VPC layers through the consuming root module or Terragrunt configuration. Keep account-specific configuration outside this reusable module. The Terraform-managed Helm release must use the exact namespace and service-account name supplied here and must configure IRSA with `role_arn`. Do not place credentials, tokens, or other secrets in module inputs, variable files, outputs, or documentation.

## Compatibility and feature policy

The supported baseline is pinned as a unit. Do not float one component or independently override the controller image without a documented compatibility review.

| Component | Selected baseline | Ownership |
|---|---|---|
| AWS LBC Helm chart | `eks/aws-load-balancer-controller` `3.5.0` | Terraform platform layer |
| AWS Load Balancer Controller | `v3.5.0` | Terraform platform layer |
| Kubernetes / EKS | `1.36` | Terraform |
| Gateway API standard CRDs | `v1.6.0` | Terraform platform layer |
| AWS LBC-specific Gateway CRDs | Pinned to controller release `v3.5.0` | Terraform platform layer |
| Application `Service` and `HTTPRoute` | Application-defined | Argo CD |

Gateway API requires AWS LBC `v2.14` or later; this baseline exceeds that minimum. Before every upgrade, compare this custom policy with the upstream `docs/install/iam_policy.json` at the exact target controller release tag, never with `main`.

### Intentional IAM differences from upstream `v3.5.0`

The upstream tag-pinned policy is a broad feature policy. This module narrows it to the enabled ALB/Gateway API path and to this account, Region, cluster, and VPC where AWS IAM condition keys support that restriction.

| Area | This module | Upstream `v3.5.0` policy | Reason and tradeoff |
|---|---|---|---|
| Load balancer family | Application-load-balancer ARN patterns only | Includes both ALB and NLB resource patterns | Deliberately excludes NLB. Enabling NLB requires a policy and platform review. |
| Optional integrations | Excludes Cognito, WAF, WAFv2, and Shield actions | Includes their actions | These features are out of scope; enabling one must be explicit. |
| Resource scope | Uses this account/Region's ALB, listener, listener-rule, target-group, security-group, and VPC ARNs where possible | Uses broader wildcard resource scope for several operations | Reduces blast radius, but the policy must be reassessed if the controller introduces actions with different resource-level authorization semantics. |
| Cluster isolation | Uses the exact `elbv2.k8s.aws/cluster` request or resource tag for selected create, mutate, and delete operations | Requires the controller tag to be present through `Null` conditions | Makes ownership explicit for this cluster; resources without the expected tag are intentionally not manageable. |
| Security-group rules | Restricts ingress authorization and revocation to `vpc_id` | Permits those actions against wildcard resources | Limits changes to the module's VPC. |
| Listener and ALB updates | Separates actions by their resource type | Groups several actions under a wildcard resource | Preserves least privilege for actions whose authorization target is known. |

`elasticloadbalancing:ModifyListenerAttributes` is scoped to ALB listener ARNs because the action operates on a listener. `elasticloadbalancing:ModifyCapacityReservation` and `elasticloadbalancing:ModifyIpPools` are scoped to ALB ARNs because those actions operate on the load balancer, not on a listener or target group. All three remain limited to application load balancers; the two load-balancer actions also require the controller's exact cluster resource tag.

### HTTPS certificate permissions

The project's HTTPS path uses ACM certificates. `acm:ListCertificates` and `acm:DescribeCertificate` allow the controller to discover and describe ACM certificates.

`elasticloadbalancing:AddListenerCertificates` and `elasticloadbalancing:RemoveListenerCertificates` have a separate responsibility: they attach and remove certificates on ALB listeners. Legacy IAM Server Certificates are intentionally unsupported and excluded from this policy.

### Feature scope

This policy supports ALB/Gateway API L7 resources. NLB, WAF, Shield, Cognito, and legacy IAM Server Certificates are excluded. Enable an excluded capability only after the Terraform platform configuration and IAM policy have been reviewed against the exact controller release.

## Non-goals

- Installing or configuring the AWS Load Balancer Controller; that belongs to a separate Terraform platform-addons module
- Managing Gateway API CRDs, AWS LBC CRDs, GatewayClass, or Gateway; those belong to the Terraform platform layer
- Managing HTTPRoute or application workloads; those belong to the Argo CD-managed product layer
- Creating load balancers, listeners, target groups, certificates, DNS records, or security groups directly
- Managing EKS, its OIDC provider, VPC networking, or Terraform state backends
- Supporting optional controller capabilities without an explicit IAM and platform-configuration review

## Verification

Run only local validation from this directory:

```bash
terraform fmt -check
terraform init -backend=false -input=false -no-color
terraform validate -no-color
```

After applying through an approved environment workflow, verify that the Terraform-managed Helm service-account annotation equals `role_arn`, its namespace/name match the outputs, and controller logs show successful web-identity role assumption. Do not use `plan` or `apply` for this module without approved environment configuration and credentials.

## Upgrade checklist

1. Pin the target Helm chart and controller versions in Terraform, and confirm the chart's shipped controller version.
2. Pin matching Gateway API standard CRDs and AWS LBC-specific Gateway CRDs in the Terraform platform layer.
3. Compare the module policy with the upstream policy at that exact controller release tag.
4. Review any proposed NLB, WAF, Shield, Cognito, or other optional capability against both platform configuration and IAM permissions.
5. Validate in a non-production environment and confirm IRSA token exchange and reconciler logs.
6. Promote only after reviewing the generated Terraform plan in the consuming environment.

## Security notes and known limitations

- Trust is restricted to one OIDC provider, one service-account subject, and the STS audience.
- Several controller permissions necessarily use wildcard resources for AWS discovery or create operations; resource-tag and VPC conditions restrict selected mutating operations.
- The module cannot verify that the separate Terraform Helm release, service-account annotation, chart version, CRDs, or enabled controller features match its IAM policy.
- Its custom policy can drift from AWS LBC releases. The exact-release comparison above is mandatory before upgrades or optional-feature enablement.
- The policy contains ALB-specific resource ARNs and does not establish support for NLB, WAF, Shield, or Cognito by itself.
- The ACM-only policy intentionally excludes legacy IAM Server Certificate permissions; ACM discovery and ELB listener-certificate operations remain distinct responsibilities.
