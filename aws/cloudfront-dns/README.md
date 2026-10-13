# Frontend DNS for CloudFront
Creates one Cloudflare CNAME pointing the frontend hostname to an
existing CloudFront distribution.

## Inputs

- `cloudflare_zone_id`: zone containing the frontend hostname.
- `frontend_domain_name`: hostname covered by the distribution's
    viewer certificate and configured as a distribution alias.
- `distribution_domain_name`: CloudFront hostname only, without
    scheme or path.

The record uses TTL 300 and disables the Cloudflare proxy.

## Ownership and credentials

This module owns only the frontend CNAME, not ACM validation records.
Check for an existing record before deployment. If one exists,
review ownership and import it rather than creating a duplicate.

Supply credentials through `CLOUDFLARE_API_TOKEN`, scoped to the
required zone. Never put tokens in Terraform inputs or repository files.

## Checks

Run from the module directory:

    terraform init -backend=false
    terraform validate
    terraform test

Tests use mocked AWS and Cloudflare providers. They verify the
record contract and reject a URL as the target; they do not verify
live DNS resolution.

The AWS provider requirement supports the shared live configuration.
This module does not create AWS resources.

For shared live configuration, use the configured AWS profile or role.
Never place AWS credentials in Terraform inputs or repository files.