locals {
  certificate_domains = distinct(concat(
    [var.domain_name],
    var.subject_alternative_names
  ))
  validation_domains = toset([
    for domain in local.certificate_domains :
    trimsuffix(trimprefix(domain, "*."), ".")
  ])
}

resource "cloudflare_dns_record" "acm_validation" {
  for_each = local.validation_domains
  zone_id  = var.cloudflare_zone_id
  name = [
    for option in aws_acm_certificate.cert.domain_validation_options :
    trimsuffix(option.resource_record_name, ".")
    if trimsuffix(trimprefix(option.domain_name, "*."), ".") == each.key
  ][0]
  type = [
    for option in aws_acm_certificate.cert.domain_validation_options :
    option.resource_record_type
    if trimsuffix(trimprefix(option.domain_name, "*."), ".") == each.key
  ][0]
  content = [
    for option in aws_acm_certificate.cert.domain_validation_options :
    trimsuffix(option.resource_record_value, ".")
    if trimsuffix(trimprefix(option.domain_name, "*."), ".") == each.key
  ][0]
  ttl     = 300
  proxied = false
}