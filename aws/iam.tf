data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Upload Lambda Role

resource "aws_iam_role" "upload_lambda" {
  name               = "${local.prefix}-upload-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "upload_basic" {
  role       = aws_iam_role.upload_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "upload_vpc" {
  role       = aws_iam_role.upload_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "upload_s3" {
  name = "${local.prefix}-upload-s3-policy"
  role = aws_iam_role.upload_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PutObjectUploadsOnly"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.images.arn}/${local.upload_prefix}*"
      }
    ]
  })
}

# Crop Lambda Role

resource "aws_iam_role" "crop_lambda" {
  name               = "${local.prefix}-crop-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "crop_basic" {
  role       = aws_iam_role.crop_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "crop_vpc" {
  role       = aws_iam_role.crop_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "crop_s3_sqs" {
  name = "${local.prefix}-crop-s3-sqs-policy"
  role = aws_iam_role.crop_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "GetObjectFromUploads"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.images.arn}/${local.upload_prefix}*"
      },
      {
        Sid      = "PutObjectToProcessed"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.images.arn}/${local.processed_prefix}*"
      },
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.image_queue.arn
      }
    ]
  })
}