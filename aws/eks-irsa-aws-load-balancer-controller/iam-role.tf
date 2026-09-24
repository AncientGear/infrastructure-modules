resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.this.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = aws_iam_policy.aws_load_balancer_controller

  role       = aws_iam_role.this.name
  policy_arn = each.value.arn
}