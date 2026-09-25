mock_provider "aws" {}

variables {
  env         = "test"
  eks_name    = "cluster"
  eks_version = "1.30"
  subnet_ids  = ["subnet-11111111", "subnet-22222222"]
  node_groups = {}
  enable_irsa = false
}

run "disabled_by_default" {
  command = plan

  assert {
    condition     = length(aws_eks_addon.coredns) == 0
    error_message = "CoreDNS must remain unmanaged by default."
  }
}

run "enabled_configuration" {
  command = plan

  variables {
    coredns = {
      enabled                   = true
      addon_version             = "v1.11.1-eksbuild.1"
      corefile                  = ".:53 { errors }"
      replica_count             = 3
      workload_toleration_value = "dns"
    }
  }

  assert {
    condition     = length(aws_eks_addon.coredns) == 1 && aws_eks_addon.coredns[0].addon_name == "coredns" && aws_eks_addon.coredns[0].cluster_name == aws_eks_cluster.this.name
    error_message = "Enabled CoreDNS must target the cluster."
  }

  assert {
    condition     = aws_eks_addon.coredns[0].addon_version == "v1.11.1-eksbuild.1" && aws_eks_addon.coredns[0].preserve && aws_eks_addon.coredns[0].resolve_conflicts_on_create == "NONE" && aws_eks_addon.coredns[0].resolve_conflicts_on_update == "NONE"
    error_message = "CoreDNS must retain explicit version and safe lifecycle settings."
  }

  assert {
    condition     = jsondecode(aws_eks_addon.coredns[0].configuration_values) == { replicaCount = 3, corefile = ".:53 { errors }", tolerations = [{ key = "CriticalAddonsOnly", operator = "Exists" }, { key = "node-role.kubernetes.io/control-plane", operator = "Exists", effect = "NoSchedule" }, { key = "workload", operator = "Equal", value = "dns", effect = "NoSchedule" }] }
    error_message = "CoreDNS configuration must include the baseline and workload tolerations."
  }
}

run "omits_optional_configuration" {
  command = plan
  variables {
    coredns = { enabled = true }
  }
  assert {
    condition     = !contains(keys(jsondecode(aws_eks_addon.coredns[0].configuration_values)), "corefile") && jsondecode(aws_eks_addon.coredns[0].configuration_values).replicaCount == 2 && length(jsondecode(aws_eks_addon.coredns[0].configuration_values).tolerations) == 2
    error_message = "Optional settings must be omitted with safe defaults."
  }
}

run "reject_invalid_replica_count" {
  command = plan
  variables {
    coredns = { enabled = true, replica_count = 0 }
  }
  expect_failures = [var.coredns]
}

run "reject_empty_version" {
  command = plan
  variables {
    coredns = { enabled = true, addon_version = "  " }
  }
  expect_failures = [var.coredns]
}

run "reject_empty_workload_value" {
  command = plan
  variables {
    coredns = { enabled = true, workload_toleration_value = " " }
  }
  expect_failures = [var.coredns]
}
