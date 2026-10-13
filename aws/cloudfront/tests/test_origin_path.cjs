const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const distribution = fs.readFileSync(
    path.join(root, "distribution.tf"), "utf8"
);
const variables = fs.readFileSync(
    path.join(root, "variables.tf"), "utf8"
);

test("current mode selects the stable prefix and preserves release mode", () => {
    assert.match(
    distribution,
    /origin_path\s*=\s*var\.frontend_origin_mode\s*==\s*"current"\s*\?\s*"\/current"\s*:\s*"\/releases\/\$\{var\.frontend_release_id\}"/
    );
});

test("release mode remains the default for existing consumers", () => {
    assert.match(
    variables,
    /variable\s+"frontend_origin_mode"\s*\{[^}]*default\s*=\s*"release"/
    );
});