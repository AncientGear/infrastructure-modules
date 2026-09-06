resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
  numeric = true
  lower   = true
}
resource "aws_s3_bucket" "this" {
  bucket        = "${var.bucket_prefix_name}-${random_string.random.result}"
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name = "${var.bucket_prefix_name}-${random_string.random.result}"
    }
  )
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}
