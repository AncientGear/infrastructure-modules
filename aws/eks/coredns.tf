resource "aws_eks_addon" "coredns" {
  count = var.coredns.enabled ? 1 : 0

  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "coredns"
  addon_version = var.coredns.addon_version
  configuration_values = jsonencode(merge(
    {
      replicaCount = var.coredns.replica_count
      tolerations = concat(
        [
          { key = "CriticalAddonsOnly", operator = "Exists" },
          { key = "node-role.kubernetes.io/control-plane", operator = "Exists", effect = "NoSchedule" }
        ],
        var.coredns.workload_toleration_value == null ? [] : [
          { key = "workload", operator = "Equal", value = var.coredns.workload_toleration_value, effect = "NoSchedule" }
        ]
      )
    },
    var.coredns.corefile == null ? {} : { corefile = var.coredns.corefile }
  ))

  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "NONE"
  preserve                    = true

  depends_on = [aws_eks_node_group.this]
}
