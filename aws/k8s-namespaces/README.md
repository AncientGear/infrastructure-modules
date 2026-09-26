# EKS namespace ownership

This standalone Terraform module owns the platform Gateway namespace and the application namespaces authorized to attach HTTPRoutes. Requires Terraform >= 1.9 and Kubernetes provider ~> 3.2; configure the provider in the calling root. Inputs: `platform_namespace` (default `gateway-system`) and the non-empty set `authorized_application_namespaces`. Outputs have the same names; application namespace output is sorted. Each application namespace receives `gateway.platform.deal-engine.io/authorized=true`. The platform name must not overlap the application set.

## Destruction boundary

No Terraform `prevent_destroy` rule protects these resources. Enforce explicit namespace deletion consent in orchestration before destroying this unit or removing a namespace from its set. A direct destroy of this unit is destructive. Destroying EKS destroys everything in the cluster, regardless of unit-level protection. Coordinate with application owners; this module does not provide an enforcement mechanism for out-of-band Kubernetes deletion.

## Existing objects

Do not apply this module to existing namespaces until the manual state handoff in [the Gateway migration runbook](../k8s-gateway/README.md#breaking-manual-state-migration) is complete. Import existing namespace objects; do not recreate them.

Offline check after provider initialization (`terraform init -backend=false`): `terraform test`. Tests use a mocked Kubernetes provider and plan only; they do not prove cluster behavior.
