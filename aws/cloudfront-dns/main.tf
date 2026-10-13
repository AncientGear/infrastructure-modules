resource "cloudflare_dns_record" "frontend" {
  zone_id = var.cloudflare_zone_id
  name    = var.frontend_domain_name
  type    = "CNAME"
  content = var.distribution_domain_name
  ttl     = 300
  proxied = false
}