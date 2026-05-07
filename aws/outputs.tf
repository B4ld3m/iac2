# aws/outputs.tf

output "api_gateway_url" {
  description = "URL del API Gateway HTTP API"
  value       = "https://${aws_apigatewayv2_api.http_api.id}.execute-api.${var.aws_region}.amazonaws.com"
}

output "api_gateway_id" {
  description = "ID del API Gateway"
  value       = aws_apigatewayv2_api.http_api.id
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.images.id
}

output "upload_lambda_name" {
  description = "Nombre de la Lambda de upload"
  value       = aws_lambda_function.upload.function_name
}

output "crop_lambda_name" {
  description = "Nombre de la Lambda de crop"
  value       = aws_lambda_function.crop.function_name
}

output "sqs_queue_url" {
  description = "URL de la cola SQS principal"
  value       = aws_sqs_queue.image_queue.url
}

output "sqs_dlq_url" {
  description = "URL del Dead Letter Queue"
  value       = aws_sqs_queue.image_dlq.url
}

output "vpc_id" {
  description = "ID del VPC"
  value       = aws_vpc.main.id
}

output "environment" {
  description = "Entorno activo"
  value       = terraform.workspace
}