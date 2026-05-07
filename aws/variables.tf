variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  default     = "image-processor"
}

# VPC 

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

# S3 

variable "s3_uploads_expiration_days" {
  type = map(number)
  default = {
    dev  = 7
    qa   = 15
    prod = 30
  }
}

variable "s3_processed_expiration_days" {
  type = map(number)
  default = {
    dev  = 30
    qa   = 60
    prod = 90
  }
}

# LAMBDA 

variable "upload_lambda_memory" {
  type    = number
  default = 256
}

variable "upload_lambda_timeout" {
  type    = number
  default = 30
}

variable "crop_lambda_memory" {
  type    = number
  default = 512
}

variable "crop_lambda_timeout" {
  type    = number
  default = 60
}

variable "lambda_log_retention_days" {
  type    = number
  default = 14
}

# SQS 

variable "sqs_visibility_timeout" {
  type    = number
  default = 360
}

variable "sqs_message_retention_seconds" {
  type    = number
  default = 86400
}

variable "sqs_dlq_retention_seconds" {
  type    = number
  default = 1209600
}

variable "sqs_max_receive_count" {
  type    = number
  default = 3
}

# API GATEWAY 

variable "apigw_throttling_rate" {
  type    = number
  default = 10000
}

variable "apigw_throttling_burst" {
  type    = number
  default = 5000
}

# ALARMA 

variable "alarm_email" {
  description = "Email para recibir alertas de la DLQ"
  type        = string
  default     = "alexanderbaljul@gmail.com"
}