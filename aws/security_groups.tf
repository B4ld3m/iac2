# SG: upload-lambda

resource "aws_security_group" "upload_lambda" {
  name        = "${local.prefix}-sg-upload-lambda"
  description = "SG para upload Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "HTTPS hacia VPC endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.prefix}-sg-upload-lambda" }
}

# SG: crop-lambda

resource "aws_security_group" "crop_lambda" {
  name        = "${local.prefix}-sg-crop-lambda"
  description = "SG para crop Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "HTTPS hacia VPC endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.prefix}-sg-crop-lambda" }
}

# SG: VPC Endpoint SQS

resource "aws_security_group" "vpce_sqs" {
  name        = "${local.prefix}-sg-vpce-sqs"
  description = "SG para SQS Interface VPC Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTPS desde upload Lambda"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.upload_lambda.id]
  }

  ingress {
    description     = "HTTPS desde crop Lambda"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.crop_lambda.id]
  }

  tags = { Name = "${local.prefix}-sg-vpce-sqs" }
}