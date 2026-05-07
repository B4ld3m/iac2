# API Gateway HTTP API v2

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.prefix}-api"
  protocol_type = "HTTP"
  description   = "Image upload API - ${local.env}"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type", "x-amz-date", "authorization"]
    max_age       = 300
  }

  tags = { Name = "${local.prefix}-api" }
}

#─ Stage por defecto con auto-deploy

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = var.apigw_throttling_rate
    throttling_burst_limit = var.apigw_throttling_burst
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      sourceIp       = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      responseLength = "$context.responseLength"
    })
  }

  tags = { Name = "${local.prefix}-stage-default" }
}

# Integración con upload Lambda

resource "aws_apigatewayv2_integration" "upload" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.upload.invoke_arn
  payload_format_version = "2.0"
}

# Ruta: POST /upload

resource "aws_apigatewayv2_route" "upload" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload.id}"
}