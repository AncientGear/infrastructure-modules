data "aws_iam_policy_document" "aws_load_balancer_controller" {
  // service linked role for the AWS Load Balancer Controller
  statement {
    sid = "ServiceLinkedRole"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    effect = "Allow"

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }

    resources = ["*"]
  }

  // EC2/ELB discovery permissions
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

    effect = "Allow"

    resources = ["*"]
  }

  // Certificate Manager permissions
  statement {
    sid = "CertificateManager"

    actions = [
      "acm:ListCertificates",
      "acm:DescribeCertificate"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  // Security Group Discovery permissions
  statement {
    sid = "SecurityGroupDiscoveryPermissions"

    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeSecurityGroupVpcAssociations",
      "ec2:GetSecurityGroupsForVpc",
      "ec2:DescribeVpcPeeringConnections",
    ]

    effect = "Allow"

    resources = ["*"]
  }

  // Create Security Group permissions
  statement {
    sid = "SecurityGroupManagementPermissions"

    actions = [
      "ec2:CreateSecurityGroup"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  // Delete Security Group permissions
  statement {
    sid = "DeleteSecurityGroupPermissions"

    actions = [
      "ec2:DeleteSecurityGroup",
    ]

    effect = "Allow"

    resources = ["arn:aws:ec2:${var.aws_region}:${local.account_id}:security-group/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  // Create tagging for Security Group permissions
  statement {
    sid = "CreateTaggingForSecurityGroupPermissions"

    actions = [
      "ec2:CreateTags"
    ]

    effect = "Allow"

    resources = ["arn:aws:ec2:${var.aws_region}:${local.account_id}:security-group/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["${var.cluster_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }
  }

  // Security Group delete tagging permissions
  statement {
    sid = "SecurityGroupDeleteTaggingPermissions"

    actions = [
      "ec2:DeleteTags"
    ]

    effect = "Allow"

    resources = ["arn:aws:ec2:${var.aws_region}:${local.account_id}:security-group/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  // Permission to add/remove inbound and outbound rules to VPC security groups
  statement {
    sid = "SecurityGroupRuleManagementPermissions"

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress"
    ]

    effect = "Allow"

    resources = ["arn:aws:ec2:${var.aws_region}:${local.account_id}:security-group/*"]

    condition {
      test     = "ArnEquals"
      variable = "ec2:Vpc"
      values = [
        "arn:aws:ec2:${var.aws_region}:${local.account_id}:vpc/${var.vpc_id}"
      ]
    }
  }

  // create ALB permissions
  statement {
    sid = "CreateALBPermissions"

    actions = [
      "elasticloadbalancing:CreateLoadBalancer"
    ]

    effect = "Allow"

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  // create target group permissions
  statement {
    sid = "CreateTargetGroupPermissions"

    actions = [
      "elasticloadbalancing:CreateTargetGroup"
    ]

    effect = "Allow"

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  // Allow AddTags to ALB permissions
  statement {
    sid = "AllowAddTagsToALBPermissions"

    actions = [
      "elasticloadbalancing:AddTags"
    ]

    effect = "Allow"

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

  // Allow AddTags to target group permissions
  statement {
    sid = "AllowAddTagsToTargetGroupPermissions"

    actions = [
      "elasticloadbalancing:AddTags"
    ]

    effect = "Allow"

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

  // Allow RemoveTags from ALB permissions
  statement {
    sid = "AllowRemoveTagsFromALBPermissions"
    actions = [
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:AddTags"
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:loadbalancer/app/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  // Allow RemoveTags from target group permissions
  statement {
    sid = "AllowRemoveTagsFromTargetGroupPermissions"

    actions = [
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:AddTags"
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:targetgroup/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  // Create Listeners permissions
  statement {
    sid = "CreateListenersPermissions"

    actions = [
      "elasticloadbalancing:CreateListener",
    ]

    effect = "Allow"

    resources = ["*"]
  }

  // Delete/Modify Listeners permissions
  statement {
    sid = "DeleteModifyListenersPermissions"

    actions = [
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyListenerAttributes"
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener/app/*/*/*"]
  }

  // Create Rules permissions
  statement {
    sid = "CreateRulesPermissions"

    actions = [
      "elasticloadbalancing:CreateRule",
    ]

    effect = "Allow"

    resources = ["*"]
  }

  // Delete/Modify Rules permissions
  statement {
    sid = "DeleteModifyRulesPermissions"

    actions = [
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:ModifyRule"
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener-rule/app/*/*/*/*"]
  }

  // Allow add/remove tags for listener permissions
  statement {
    sid = "AllowAddRemoveTagsForListenerPermissions"

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener/app/*/*/*"]
  }

  // Allow add/remove tags for listener rule permissions
  statement {
    sid = "AllowAddRemoveTagsForListenerRulePermissions"

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener-rule/app/*/*/*/*"]
  }

  // Allow add listener certificates permissions
  statement {
    sid = "AllowAddListenerCertificatesPermissions"

    actions = [
      "elasticloadbalancing:AddListenerCertificates",
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener/app/*/*/*"]
  }

  // Allow remove listener certificates permissions
  statement {
    sid = "AllowRemoveListenerCertificatesPermissions"

    actions = [
      "elasticloadbalancing:RemoveListenerCertificates",
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener/app/*/*/*"]
  }

  // Allow set rule priorities permissions
  statement {
    sid = "AllowSetRulePrioritiesPermissions"

    actions = [
      "elasticloadbalancing:SetRulePriorities",
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:listener-rule/app/*/*/*/*"]
  }

  // Allow modify/delete ALB
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

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:loadbalancer/app/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }



  // Allow modify/delete target group
  statement {
    sid = "AllowModifyDeleteTargetGroupPermissions"

    actions = [
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes"
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:targetgroup/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  // Allow Register/Deregister targets permissions
  statement {
    sid = "AllowRegisterDeregisterTargetsPermissions"

    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets"
    ]

    effect = "Allow"

    resources = ["arn:aws:elasticloadbalancing:${var.aws_region}:${local.account_id}:targetgroup/*/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = var.aws_load_balancer_controller_policy_name
  description = "IAM policy for the AWS Load Balancer Controller"
  policy      = data.aws_iam_policy_document.aws_load_balancer_controller.json
}
