# EKS module: optional managed CoreDNS

CoreDNS remains unmanaged by default. To manage the EKS add-on, pass `coredns`:

```hcl
coredns = {
  enabled                     = true
  addon_version               = "<version verified for this cluster>"
  replica_count               = 2
  workload_toleration_value   = "dns" # optional; adds a workload= dns NoSchedule toleration
  corefile                    = "<your Corefile>" # optional; omitted unless explicitly provided
}
```

Verify the add-on version against your cluster version externally before enabling it; this module does not query AWS compatibility. The default tolerations allow `CriticalAddonsOnly` and the control-plane `NoSchedule` taint. A workload toleration is appended only when requested. A Corefile is **not** inferred or overwritten unless you explicitly supply one.

Adopting an existing self-managed CoreDNS installation may surface conflicts. Both create and update conflict resolution are `NONE`: the module will not silently overwrite existing settings. Resolve any conflicts deliberately before retrying. `preserve = true` retains the add-on when this resource is removed from Terraform management (including disabling `coredns`), rather than abruptly uninstalling cluster DNS. Plan that transition carefully: disabling management does not revert settings or remove CoreDNS. Cluster destruction is different: destroying the EKS cluster also removes its DNS regardless of add-on preservation.

Offline checks (with locally installed providers): `terraform test -test-directory=tests` from `aws/eks`. Tests mock AWS and do not apply infrastructure.
