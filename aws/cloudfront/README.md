# CloudFront frontend delivery

Serves a selected frontend release from private S3 and forwards API
requests to an existing internal ALB through a CloudFront VPC Origin.

## Routing

| Path | Origin | CloudFront caching |
| --- | --- | --- |
| `/assets/*` | Selected S3 release | Managed-CachingOptimized |
| `/api`, `/api/*` | Internal ALB | Disabled |
| Other paths | Selected S3 release; SPA rewrite | Disabled |

SPA routes resolve to `/index.html`. API paths are never rewritten.
API requests retain their path and authorization header. The viewer
Host header is replaced with the configured origin hostname.

## Required configuration

- `frontend_release_id`: existing `run_id-run_attempt` release under
    `releases/`, containing `index.html` and `assets/`.
- `alb_origin_arn`: ARN of the active internal ALB.
- `alb_origin_domain_name`: origin hostname matching its HTTPS
    certificate and Kubernetes Gateway/HTTPRoute.
- `vpc_origin_name`: CloudFront VPC Origin name.
- `acm_certificate_arn`: issued viewer certificate in `us-east-1`.
- `aliases`: frontend domains covered by that certificate.
- S3 bucket inputs: existing private bucket and its regional domain.
- `cloudfront_origin_access_control_id`: name used to create the OAC,
    despite the legacy input name.

## Ownership and prerequisites

Terraform manages CloudFront, the VPC Origin, OAC and bucket policy.
Kubernetes manages the ALB. This module does not modify ALB security
groups or create frontend DNS records.

VPC Origin networking and permissions must be checked before deployment.
Only one Terraform owner should manage the bucket policy.

Publishing files to S3 does not activate a release: promotion explicitly
changes `frontend_release_id`. Keep prior releases for rollback.

Cached asset URLs must be immutable and content-hashed. Changing the
release origin path does not invalidate existing `/assets/*` cache entries.
If an asset URL is reused with different content, invalidate that URL
before relying on the new content.

The SPA rewrite uses a filename heuristic: paths whose final segment
contains a dot are preserved, except paths ending with `/`.

## Compatibility and checks

This revision requires new inputs and replaces the previous `/content/*`
cache behaviors. Publish a new module tag; never move existing tags.

Run from the project root:

    node infrastructure-modules/aws/cloudfront/tests/test_spa_rewrite.cjs
    terraform -chdir=infrastructure-modules/aws/cloudfront fmt -check
    terraform -chdir=infrastructure-modules/aws/cloudfront validate

These checks do not prove live origin connectivity.
New required inputs: `frontend_release_id`, `alb_origin_arn` and
`vpc_origin_name`. Consumers must supply these inputs when upgrading.
The `/assets/*` behavior replaces the previous `/content/*` behaviors.
 el bloqueo se dispara por el nombre del directorio secrets, no por el contenido.
 En gentle-pi/extensions/gentle-ai.ts:1627 está esta regla fija:
/(^|\/)secrets(?:\/|$)/
 Bloquea read, write y edit sobre cualquier ruta con ese directorio. No distingue código fuente de archivos con
 credenciales reales ni reevalúa el riesgo criptográfico.