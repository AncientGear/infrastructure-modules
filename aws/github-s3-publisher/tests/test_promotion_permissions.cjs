const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const permissions = fs.readFileSync(
    path.join(root, "permissions.tf"), "utf8"
);
const variables = fs.readFileSync(
    path.join(root, "variables.tf"), "utf8"
);

test("promotion permissions are optional and include scoped resources", () => {
    assert.match(
    variables,
    /variable\s+"enable_promotion"\s*\{[^}]*default\s*=\s*false/
    );
    assert.match(
    permissions,
    /for_each\s*=\s*var\.enable_promotion\s*\?\s*\[1\]\s*:\s*\[\]/
    );

    for (const action of [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket",
    "cloudfront:CreateInvalidation",
    ]) {
    assert.ok(permissions.includes(`"${action}"`), action);
    }

    assert.ok(permissions.includes('"${var.bucket_arn}/releases/*"'));
    assert.ok(permissions.includes('"${var.bucket_arn}/current/*"'));
    assert.ok(permissions.includes("var.cloudfront_distribution_arn"));
});

test("existing upload permission remains and destructive actions are absent", () => {
    assert.ok(permissions.includes('sid       = "UploadReleaseObjects"'));
    assert.ok(permissions.includes('"${var.bucket_arn}/releases/*"'));
    assert.ok(!permissions.includes("s3:DeleteObject"));
    assert.ok(!permissions.includes("cloudfront:UpdateDistribution"));
});