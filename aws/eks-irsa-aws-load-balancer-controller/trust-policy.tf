data "aws_iam_policy_document" "this" {

  statement {
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = [local.subject_service_account]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    effect = "Allow"
  }
}

