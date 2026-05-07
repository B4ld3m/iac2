# S3 Bucket

resource "aws_s3_bucket" "images" {
  bucket        = local.bucket_name
  force_destroy = local.env != "prod"

  tags = { Name = local.bucket_name }
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket                  = aws_s3_bucket.images.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    id     = "expire-uploads"
    status = "Enabled"
    filter { prefix = local.upload_prefix }
    expiration {
      days = lookup(var.s3_uploads_expiration_days, local.env, 30)
    }
  }

  rule {
    id     = "expire-processed"
    status = "Enabled"
    filter { prefix = local.processed_prefix }
    expiration {
      days = lookup(var.s3_processed_expiration_days, local.env, 90)
    }
  }
}

resource "aws_s3_bucket_notification" "uploads_to_sqs" {
  bucket = aws_s3_bucket.images.id

  queue {
    queue_arn     = aws_sqs_queue.image_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = local.upload_prefix
  }

  depends_on = [aws_sqs_queue_policy.allow_s3]
}