resource "aws_cloudfront_function" "spa_rewrite" {
  name    = "${var.bucket_id}-${var.function_name}"
  runtime = "cloudfront-js-2.0"
  comment = "Rewrite SPA routes to index.html"
  publish = true
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      var uri = request.uri;
      if (uri.startsWith('/api/')) {
        return request;
      }
      if (uri.endsWith('/')) {
        request.uri += 'index.html';
        return request;
      }
      var lastSegment = uri.split('/').pop();
      if (!lastSegment.includes('.')) {
        request.uri = '/index.html';
      }
      return request;
    }
  EOT
}
