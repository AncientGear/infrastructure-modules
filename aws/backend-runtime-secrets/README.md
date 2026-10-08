# Backend runtime secrets (dev only)

Local preparation only; no deployment or live verification has occurred.
This module owns a dedicated IRSA role/policy and a bundled Helm release
containing only a ServiceAccount, namespaced SecretStore and ExternalSecret.
Argo remains the sole owner of backend Deployment, Service and HTTPRoute.
The module does not create or adopt the pre-existing `backend-dev` namespace.

## Prerequisites and ordering

1. Publish/release this module and the ESO module; convert development-only
   sibling sources to immutable released references before deployment.
2. Ensure EKS OIDC and `backend-dev` exist. Deploy the separately managed ESO
   chart pinned to **2.11.0**, including its `external-secrets.io/v1` CRDs;
   verify operator and webhook readiness before this release.
3. An authorized operator must separately pre-provision the AWS Secrets Manager
   JSON application secret `dev/dealengine/backend-runtime` in the configured
   account/region with nonempty `DATABASE_URL` and `TOKEN_SECRET` properties.
   Seeding and rotation are manual prerequisites, not completed automation.
   Never supply values through Terraform, Helm, Git or verification logs.
   Provision the complete URL externally; no ESO URL construction/escaping is
   assumed. Retain the backend's TLS hostname verification requirements.
4. Deploy this release only after the above gates. Terragrunt dependency paths
   order units in a dependency-aware run; they do not prove readiness and do not
   cause prerequisites to deploy when applying this unit alone.
5. Verify SecretStore/ExternalSecret Ready and target Secret key presence without
   printing values before permitting backend startup or Argo synchronization.
   Helm wait does not guarantee ExternalSecret reconciliation readiness.

## Security and ownership

Trust uses exact `StringEquals` subject
`system:serviceaccount:backend-dev:backend-runtime-secrets` and audience
`sts.amazonaws.com`, bound to the supplied EKS OIDC provider. This ServiceAccount
is for ESO JWT authentication, not for the backend workload.

Read permission covers only GetSecretValue/DescribeSecret on the exact name plus
AWS's six-character ARN suffix (`-??????`), never a path-wide wildcard. There is
no secret resource/version or secret material in Terraform; inputs are
identifiers only. Use the intended account, region and matching OIDC ARN/URL.

The default AWS-managed Secrets Manager key needs no extra policy here. A
customer-managed KMS key requires separately reviewed `kms:Decrypt` permission
on its exact key ARN and compatible key policy (prefer a Secrets Manager
ViaService condition). This module deliberately does not grant KMS permissions;
CMK-encrypted sources will fail reconciliation until that prerequisite is met.

ESO owns `backend-runtime` via `creationPolicy: Owner`; do not create a competing
Secret through Argo or another release. Source deletion uses `Retain`; stale
values can remain, so deletion is not a credential revocation mechanism.
Rotation refreshes hourly; backend process reload/restart is a separate concern.

## Offline checks

Structural unittest checks, Terraform formatting and Helm lint/render are local
checks only. They do not validate IAM authorization, CRD schema admission,
provider compatibility, live reconciliation or deployment ordering readiness.
