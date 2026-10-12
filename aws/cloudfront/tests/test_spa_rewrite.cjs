const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const source = fs.readFileSync(
    path.join(__dirname, '..', 'cloudfront_function.tf'),
    'utf8',
);
const match = source.match(/<<-EOT\r?\n([\s\S]*?)^\s*EOT\s*$/m);
assert.ok(match, 'CloudFront function heredoc not found');

const sandbox = {};
vm.runInNewContext(match[1], sandbox);

for (const [input, expected] of [
    ['/', '/index.html'],
    ['/tickets', '/index.html'],
    ['/tickets/', '/index.html'],
    ['/assets/app.js', '/assets/app.js'],
    ['/assets/missing.js', '/assets/missing.js'],
    ['/api', '/api'],
    ['/api/', '/api/'],
    ['/api/login', '/api/login'],
]) {
    const result = sandbox.handler({ request: { uri: input } });
    assert.equal(result.uri, expected, input);
}

console.log('SPA rewrite tests passed');