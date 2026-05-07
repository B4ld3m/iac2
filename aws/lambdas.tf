# Empaquetar código fuente como ZIP

data "archive_file" "upload_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../src/upload-lambda"
  output_path = "${path.module}/.terraform/upload-lambda.zip"
}

data "archive_file" "crop_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../src/crop-lambda"
  output_path = "${path.module}/.terraform/crop-lambda.zip"
}

# Upload Lambda

resource "aws_lambda_function" "upload" {
  function_name    = "${local.prefix}-upload"
  role             = aws_iam_role.upload_lambda.arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = data.archive_file.upload_lambda.output_path
  source_code_hash = data.archive_file.upload_lambda.output_base64sha256
  memory_size      = var.upload_lambda_memory
  timeout          = var.upload_lambda_timeout

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.images.bucket
      UPLOAD_PREFIX = local.upload_prefix
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.upload_lambda.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.upload_basic,
    aws_iam_role_policy_attachment.upload_vpc,
    aws_cloudwatch_log_group.upload_lambda,
  ]

  tags = { Name = "${local.prefix}-upload" }
}

# Crop Lambda 

resource "aws_lambda_function" "crop" {
  function_name    = "${local.prefix}-crop"
  role             = aws_iam_role.crop_lambda.arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = data.archive_file.crop_lambda.output_path
  source_code_hash = data.archive_file.crop_lambda.output_base64sha256
  memory_size      = var.crop_lambda_memory
  timeout          = var.crop_lambda_timeout

  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.images.bucket
      PROCESSED_PREFIX = local.processed_prefix
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.crop_lambda.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.crop_basic,
    aws_iam_role_policy_attachment.crop_vpc,
    aws_cloudwatch_log_group.crop_lambda,
  ]

  tags = { Name = "${local.prefix}-crop" }
}

# SQS → Crop Lambda Event Source Mapping

resource "aws_lambda_event_source_mapping" "sqs_to_crop" {
  event_source_arn        = aws_sqs_queue.image_queue.arn
  function_name           = aws_lambda_function.crop.arn
  batch_size              = 5
  function_response_types = ["ReportBatchItemFailures"]
  enabled                 = true
}

# Permiso para que API Gateway invoque upload Lambda

resource "aws_lambda_permission" "apigw_upload" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}