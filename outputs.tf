output "courier_function_arn" {
  description = "The ARN for the Lambda function for the courier"
  value       = aws_lambda_function.courier.arn
}

output "courier_url" {
  description = "The HTTP URL endpoint for the courier"
  value       = local.is_govcloud ? aws_apigatewayv2_stage.this["enabled"].invoke_url : aws_lambda_function_url.courier["enabled"].function_url
}

output "audit_trail_storage_bucket_name" {
  description = "The name for the S3 bucket that stores the events"
  value       = module.audit_trail_s3_bucket.bucket_id
}

output "stream_name" {
  description = "The name for the Kinesis Firehose Delivery Stream"
  value       = aws_kinesis_firehose_delivery_stream.stream.name
}
