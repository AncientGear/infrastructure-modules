mock_provider "helm" {}

variables {
  cluster_name = "dev-demo"
  region       = "us-east-2"
  vpc_id       = "vpc-12345678"
  aws_load_balancer_controller = {
    enabled  = true
    role_arn = "arn:aws:iam::123456789012:role/controller"
  }
}

run "default_image_tag" {
  command = plan
  assert {
    condition     = yamldecode(helm_release.aws_load_balancer_controller[0].values[0]).image.tag == "v3.5.0"
    error_message = "Default controller image tag changed."
  }
}

run "arm_image_tag" {
  command = plan
  variables {
    aws_load_balancer_controller = {
      enabled   = true
      role_arn  = "arn:aws:iam::123456789012:role/controller"
      image_tag = "v3.5.0-arm64"
    }
  }
  assert {
    condition     = yamldecode(helm_release.aws_load_balancer_controller[0].values[0]).image.tag == "v3.5.0-arm64"
    error_message = "ARM controller tag was not propagated."
  }
}
