module "courier_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["courier"]
  context    = module.this.context
}

module "stream_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["stream"]
  context    = module.this.context
}

##################################################
# Courier
##################################################
data "archive_file" "lambda_function" {
  output_file_mode = "0666"
  output_path      = "${path.module}/function.zip"
  source_file      = "${path.module}/function.py"
  type             = "zip"
}

resource "aws_lambda_function" "courier" {
  filename         = data.archive_file.lambda_function.output_path
  function_name    = module.courier_label.id
  handler          = "function.handler"
  role             = aws_iam_role.courier.arn
  runtime          = "python${var.python_version}"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  environment {
    variables = {
      SECRET  = var.secret
      STREAM  = aws_kinesis_firehose_delivery_stream.stream.name
      VERBOSE = var.lambda_logs_verbose
    }
  }
}

resource "aws_lambda_function_url" "courier" {
  for_each = local.each_commercial

  authorization_type = "NONE" # Lambda function's authorization can only be AWS IAM or NONE. Even though this is a public endpoint, the function first checks `is_signature_valid()` before processing the request.
  function_name      = aws_lambda_function.courier.function_name
}

resource "aws_iam_role" "courier" {
  name = module.courier_label.id

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy" "courier" {
  role = aws_iam_role.courier.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "firehose:PutRecord"
        ],
        Resource = [aws_kinesis_firehose_delivery_stream.stream.arn]
      },
    ]
  })
}

resource "aws_cloudwatch_log_group" "courier" {
  name              = "/aws/lambda/${module.courier_label.id}"
  retention_in_days = var.cloudwatch_logs_retention_days
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.courier.name
}

##################################################
# Stream
##################################################
resource "aws_cloudwatch_log_group" "stream" {
  name              = "/aws/kinesisfirehose/${module.stream_label.id}"
  retention_in_days = var.cloudwatch_logs_retention_days
}

resource "aws_cloudwatch_log_stream" "destination_delivery" {
  log_group_name = aws_cloudwatch_log_group.stream.name
  name           = "DestinationDelivery"
}

resource "aws_kinesis_firehose_delivery_stream" "stream" {
  destination = "extended_s3"
  name        = module.stream_label.id

  extended_s3_configuration {
    buffering_interval  = var.buffer_interval
    buffering_size      = var.buffer_size
    bucket_arn          = module.audit_trail_s3_bucket.bucket_arn
    error_output_prefix = "error/!{firehose:error-output-type}/"
    compression_format  = "GZIP"
    prefix              = "year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    role_arn            = aws_iam_role.stream.arn

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.stream.name
      log_stream_name = aws_cloudwatch_log_stream.destination_delivery.name
    }
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }
}

resource "aws_iam_role" "stream" {
  name = module.stream_label.id

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "firehose.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy" "stream" {
  role = aws_iam_role.stream.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents"
        ],
        Resource = [
          aws_cloudwatch_log_stream.destination_delivery.arn
        ]
      },
    ]
  })
}
