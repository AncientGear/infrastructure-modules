data "aws_iam_policy_document" "aws_load_balancer_controller_discovery" {
  statement {
    sid     = "ServiceLinkedRole"
    actions = ["iam:CreateServiceLinkedRole"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid = "EC2ELBDiscovery"
    actions = [
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "ec2:DescribeIpamPools",
      "ec2:DescribeRouteTables",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTrustStores",
      "elasticloadbalancing:DescribeListenerAttributes",
      "elasticloadbalancing:DescribeCapacityReservation"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "CertificateManager"
    actions = [
      "acm:ListCertificates",
      "acm:DescribeCertificate"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "SecurityGroupDiscoveryPermissions"
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeSecurityGroupVpcAssociations",
      "ec2:GetSecurityGroupsForVpc",
      "ec2:DescribeVpcPeeringConnections"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "aws_load_balancer_controller_security_groups" {
  statement {
    sid       = "SecurityGroupManagementPermissions"
    actions   = ["ec2:CreateSecurityGroup"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid       = "DeleteSecurityGroupPermissions"
    actions   = ["ec2:DeleteSecurityGroup"]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${var.aws_region}:${local.account_id}:security-group/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid       = "CreateTaggingForSecurityGroupPermissions"
    actions   = ["ec2:CreateTags"]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${var.aws_region}:${local.account_id}:security-group/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }
  }

  statement {
    sid       = "SecurityGroupDeleteTaggingPermissions"
    actions   = ["ec2:DeleteTags"]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${var.aws_region}:${local.account_id}:security-group/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid = "SecurityGroupRuleManagementPermissions"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress"
    ]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${var.aws_region}:${local.account_id}:security-group/*"]

    condition {
      test     = "ArnEquals"
      variable = "ec2:Vpc"
      values   = ["arn:aws:ec2:${var.aws_region}:${local.account_id}:vpc/${var.vpc_id}"]
    }
  }
}

data "aws_iam_policy_document" "aws_load_balancer_controller_load_balancers" {
  statement {
    sid       = "CreateALBPermissions"
    actions   = ["elasticloadbalancing:CreateLoadBalancer"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid       = "AllowAddTagsToALBPermissions"
    actions   = ["elasticloadbalancing:AddTags"]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:loadbalancer/app/*/*"]

    condition {
      test     = "StringEquals"
      variable = "elasticloadbalancing:CreateAction"
      values   = ["CreateLoadBalancer"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid = "AllowRemoveTagsFromALBPermissions"
    actions = [
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:AddTags"
    ]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:loadbalancer/app/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid       = "CreateListenersPermissions"
    actions   = ["elasticloadbalancing:CreateListener"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "DeleteModifyListenersPermissions"
    actions = [
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyListenerAttributes"
    ]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener/app/*/*/*"]
  }

  statement {
    sid       = "CreateRulesPermissions"
    actions   = ["elasticloadbalancing:CreateRule"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "DeleteModifyRulesPermissions"
    actions = [
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:ModifyRule"
    ]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener-rule/app/*/*/*/*"]
  }

  statement {
    sid = "AllowAddRemoveTagsForListenerPermissions"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener/app/*/*/*"]
  }

  statement {
    sid = "AllowAddRemoveTagsForListenerRulePermissions"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener-rule/app/*/*/*/*"]
  }

  statement {
    sid       = "AllowAddListenerCertificatesPermissions"
    actions   = ["elasticloadbalancing:AddListenerCertificates"]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener/app/*/*/*"]
  }

  statement {
    sid       = "AllowRemoveListenerCertificatesPermissions"
    actions   = ["elasticloadbalancing:RemoveListenerCertificates"]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener/app/*/*/*"]
  }

  statement {
    sid       = "AllowSetRulePrioritiesPermissions"
    actions   = ["elasticloadbalancing:SetRulePriorities"]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener-rule/app/*/*/*/*"]
  }

  statement {
    sid = "AllowModifyDeleteALBPermissions"
    actions = [
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:ModifyCapacityReservation",
      "elasticloadbalancing:ModifyIpPools"
    ]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:loadbalancer/app/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }
}

data "aws_iam_policy_document" "aws_load_balancer_controller_target_groups" {
  statement {
    sid       = "CreateTargetGroupPermissions"
    actions   = ["elasticloadbalancing:CreateTargetGroup"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid       = "AllowAddTagsToTargetGroupPermissions"
    actions   = ["elasticloadbalancing:AddTags"]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:targetgroup/*/*"]

    condition {
      test     = "StringEquals"
      variable = "elasticloadbalancing:CreateAction"
      values   = ["CreateTargetGroup"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid = "AllowRemoveTagsFromTargetGroupPermissions"
    actions = [
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:AddTags"
    ]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:targetgroup/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid = "AllowModifyDeleteTargetGroupPermissions"
    actions = [
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes"
    ]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:targetgroup/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid = "AllowRegisterDeregisterTargetsPermissions"
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets"
    ]
    effect    = "Allow"
    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:targetgroup/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }
}

locals {
  aws_load_balancer_controller_policy_documents = {
    discovery       = data.aws_iam_policy_document.aws_load_balancer_controller_discovery.json
    security_groups = data.aws_iam_policy_document.aws_load_balancer_controller_security_groups.json
    load_balancers  = data.aws_iam_policy_document.aws_load_balancer_controller_load_balancers.json
    target_groups   = data.aws_iam_policy_document.aws_load_balancer_controller_target_groups.json
  }
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  for_each = local.aws_load_balancer_controller_policy_documents

  name        = "${var.aws_load_balancer_controller_policy_name}-${each.key}"
  description = "IAM ${each.key} policy for the AWS Load Balancer Controller"
  policy      = each.value
}
