
output "courier_url" {
  description = "The HTTP URL endpoint for the courier"
  value       = module.collector.courier_url
}

output "bucket_name" {
  description = "The ARN of the S3 bucket"
  value       = module.collector.audit_trail_storage_bucket_name
}
