mock_provider "aws" {}
mock_provider "cloudflare" {}

variables {
    cloudflare_zone_id       = "00000000000000000000000000000000"
    frontend_domain_name     = "dev.example.com"
    distribution_domain_name = "d111111abcdef8.cloudfront.net"
}

run "frontend_dns_contract" {
    command = plan

    assert {
    condition     = cloudflare_dns_record.frontend.type == "CNAME"
    error_message = "Frontend DNS must use CNAME."
    }

    assert {
    condition     = cloudflare_dns_record.frontend.proxied == false
    error_message = "Cloudflare proxy must remain disabled."
    }

    assert {
    condition     = cloudflare_dns_record.frontend.ttl == 300
    error_message = "Frontend DNS must use the explicit TTL."
    }

    assert {
    condition = (
        cloudflare_dns_record.frontend.name == var.frontend_domain_name &&
        cloudflare_dns_record.frontend.content == var.distribution_domain_name &&
        cloudflare_dns_record.frontend.zone_id == var.cloudflare_zone_id
    )
    error_message = "DNS must use the supplied zone, frontend name and distribution."
    }
}

run "reject_url_as_target" {
    command = plan

    variables {
    distribution_domain_name = "https://d111111abcdef8.cloudfront.net/"
    }

    expect_failures = [var.distribution_domain_name]
}