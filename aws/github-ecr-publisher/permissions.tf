data "aws_iam_policy_document" "publish" {
  statement {
    sid       = "GetECRAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PublishRepositoryImages"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]

    resources = [var.ecr_repository_arn]
  }
}

resource "aws_iam_role_policy" "publish" {
  name   = "publish-ecr-images"
  role   = aws_iam_role.publisher.id
  policy = data.aws_iam_policy_document.publish.json
}