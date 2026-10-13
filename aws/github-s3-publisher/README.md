# GitHub Actions S3 publisher

Creates an IAM role with an exact GitHub OIDC subject.
By default, the role can only upload objects to `releases/*`.

## Optional promotion permissions

Set `enable_promotion = true` and provide an exact
`cloudfront_distribution_arn` to enable:

- Read objects under `releases/*`.
- Write objects under `current/*`.
- List the bucket only with prefixes matching `releases/*` or `current/*`.
- Create invalidations for the specified CloudFront distribution.

No object deletion or CloudFront distribution updates are granted.
Existing consumers retain upload-only permissions by default.

## Deployment requirements

Promotion must validate the release before copying it.
Copy content-hashed assets before publishing index.html.
Retain previous assets for clients using older HTML.
Serialize promotion and rollback operations for each environment.
Copying multiple S3 objects is not atomic.

The bucket uses SSE-S3 in the current deployment. Buckets using SSE-KMS
require separately reviewed key permissions.

## Checks

Run from the project root:

    node --test infrastructure-modules/aws/github-s3-publisher/tests/test_promotion_permissions.cjs
    terraform -chdir=infrastructure-modules/aws/github-s3-publisher fmt -check
    terraform -chdir=infrastructure-modules/aws/github-s3-publisher validate

The Node tests check source structure, not effective IAM authorization.
Review the generated policy in the consumer plan before applying.