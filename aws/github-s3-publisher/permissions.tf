data "aws_iam_policy_document" "publish" {
  statement {
    sid       = "UploadReleaseObjects"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${var.bucket_arn}/releases/*"]
  }

  dynamic "statement" {
    for_each = var.enable_promotion ? [1] : []

    content {
      sid       = "ReadReleaseObjects"
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${var.bucket_arn}/releases/*"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_promotion ? [1] : []

    content {
      sid       = "WriteCurrentObjects"
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["${var.bucket_arn}/current/*"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_promotion ? [1] : []

    content {
      sid       = "ListDeploymentPrefixes"
      effect    = "Allow"
      actions   = ["s3:ListBucket"]
      resources = [var.bucket_arn]

      condition {
        test     = "StringLike"
        variable = "s3:prefix"
        values   = ["releases/*", "current/*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_promotion ? [1] : []

    content {
      sid       = "InvalidateFrontendDistribution"
      effect    = "Allow"
      actions   = ["cloudfront:CreateInvalidation"]
      resources = [var.cloudfront_distribution_arn]
    }
  }
}

resource "aws_iam_role_policy" "publish" {
  name   = "publish-s3-releases"
  role   = aws_iam_role.publisher.id
  policy = data.aws_iam_policy_document.publish.json
}