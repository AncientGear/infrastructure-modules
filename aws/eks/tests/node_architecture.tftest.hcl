mock_provider "aws" {}

variables {
  env             = "test"
  eks_name        = "cluster"
  eks_version     = "1.35"
  subnet_ids      = ["subnet-11111111", "subnet-22222222"]
  node_subnet_ids = ["subnet-11111111"]
  enable_irsa     = false
  node_groups = {
    general = {
      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.small"]
      scaling_config = { desired_size = 1, max_size = 2, min_size = 0 }
    }
  }
}

run "default_ami_and_subnet_override" {
  command = plan

  assert {
    condition     = try(var.node_groups["general"].ami_type, null) == null
    error_message = "An omitted AMI type must remain unset."
  }

  assert {
    condition     = tolist(aws_eks_node_group.this["general"].subnet_ids) == tolist(["subnet-11111111"])
    error_message = "The node group must use the node subnet override."
  }

  assert {
    condition     = tolist(aws_eks_cluster.this.vpc_config[0].subnet_ids) == tolist(["subnet-11111111", "subnet-22222222"])
    error_message = "The cluster must retain both subnets."
  }
}

run "explicit_arm_ami" {
  command = plan
  variables {
    node_groups = {
      general = {
        capacity_type  = "ON_DEMAND"
        instance_types = ["t4g.medium"]
        ami_type       = "AL2023_ARM_64_STANDARD"
        scaling_config = { desired_size = 1, max_size = 2, min_size = 0 }
      }
    }
  }

  assert {
    condition     = aws_eks_node_group.this["general"].ami_type == "AL2023_ARM_64_STANDARD"
    error_message = "The ARM node group must expose its explicit AMI type."
  }

  assert {
    condition     = tolist(aws_eks_node_group.this["general"].subnet_ids) == tolist(["subnet-11111111"]) && tolist(aws_eks_cluster.this.vpc_config[0].subnet_ids) == tolist(["subnet-11111111", "subnet-22222222"])
    error_message = "ARM nodes use the override while the cluster retains two subnets."
  }
}
