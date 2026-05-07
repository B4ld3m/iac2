# Dead-Letter Queue

resource "aws_sqs_queue" "image_dlq" {
  name                      = "${local.prefix}-image-dlq"
  message_retention_seconds = var.sqs_dlq_retention_seconds

  tags = { Name = "${local.prefix}-image-dlq" }
}

# Main Queue 

resource "aws_sqs_queue" "image_queue" {
  name                       = "${local.prefix}-image-queue"
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.image_dlq.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })

  tags = { Name = "${local.prefix}-image-queue" }
}

# Policy: permitir que S3 envíe notificaciones

resource "aws_sqs_queue_policy" "allow_s3" {
  queue_url = aws_sqs_queue.image_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Notification"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.image_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.images.arn
          }
        }
      }
    ]
  })
}