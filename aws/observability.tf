# Log Groups

resource "aws_cloudwatch_log_group" "upload_lambda" {
  name              = "/aws/lambda/${local.prefix}-upload"
  retention_in_days = var.lambda_log_retention_days
}

resource "aws_cloudwatch_log_group" "crop_lambda" {
  name              = "/aws/lambda/${local.prefix}-crop"
  retention_in_days = var.lambda_log_retention_days
}

resource "aws_cloudwatch_log_group" "apigw" {
  name              = "/aws/apigateway/${local.prefix}"
  retention_in_days = var.lambda_log_retention_days
}

# SNS Topic para alarma DLQ

resource "aws_sns_topic" "dlq_alarm" {
  name = "${local.prefix}-dlq-alarm-topic"
  tags = { Name = "${local.prefix}-dlq-alarm-topic" }
}

resource "aws_sns_topic_subscription" "dlq_alarm_email" {
  topic_arn = aws_sns_topic.dlq_alarm.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch Alarm: mensajes visibles en DLQ > 0

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${local.prefix}-dlq-messages-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alerta cuando aparecen mensajes en la Dead-Letter Queue"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.image_dlq.name
  }

  alarm_actions = [aws_sns_topic.dlq_alarm.arn]
  ok_actions    = [aws_sns_topic.dlq_alarm.arn]

  tags = { Name = "${local.prefix}-dlq-messages-alarm" }
}