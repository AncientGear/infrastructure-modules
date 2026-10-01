data "aws_iam_policy_document" "publish" {
  statement {
    sid       = "UploadReleaseObjects"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${var.bucket_arn}/releases/*"]
  }
}

resource "aws_iam_role_policy" "publish" {
  name   = "publish-s3-releases"
  role   = aws_iam_role.publisher.id
  policy = data.aws_iam_policy_document.publish.json
}