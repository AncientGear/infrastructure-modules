output "dns_record_id" {
  value = cloudflare_dns_record.frontend.id
}

output "frontend_domain_name" {
  value = cloudflare_dns_record.frontend.name
}