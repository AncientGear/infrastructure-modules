resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.cloudfront_origin_access_control_id
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}