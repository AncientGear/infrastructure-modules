locals {
  oidc_host = trimprefix(var.oidc_provider_url, "https://")
}

resource "aws_iam_role" "runtime" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = var.oidc_provider_arn }
      Condition = {
        StringEquals = {
          "${local.oidc_host}:sub" = "system:serviceaccount:backend-dev:backend-runtime-secrets"
          "${local.oidc_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "runtime" {
  name = "backend-runtime-read"
  role = aws_iam_role.runtime.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:dev/dealengine/backend-runtime-??????"
    }]
  })
}

resource "helm_release" "runtime" {
  name             = "backend-runtime-secrets"
  chart            = "${path.module}/chart"
  namespace        = var.namespace
  create_namespace = false
  atomic           = true
  wait             = true
  timeout          = 300
  depends_on       = [aws_iam_role_policy.runtime]
  values = [yamlencode({
    serviceAccount = { roleArn = aws_iam_role.runtime.arn }
    aws = {
      region     = var.region
      secretName = "dev/dealengine/backend-runtime"
    }
  })]
}
