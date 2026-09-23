output "aws_load_balancer_controller" {
  description = "AWS Load Balancer Controller installation details, or null fields when disabled."

  value = {
    enabled              = var.aws_load_balancer_controller.enabled
    release_name         = try(helm_release.aws_load_balancer_controller[0].name, null)
    namespace            = var.aws_load_balancer_controller.enabled ? var.aws_load_balancer_controller.namespace : null
    service_account_name = var.aws_load_balancer_controller.enabled ? var.aws_load_balancer_controller.service_account_name : null
  }
}
