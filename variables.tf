# Kinesis Firehose
variable "buffer_interval" {
  default     = 300
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination"
  type        = number
}

variable "buffer_size" {
  default     = 5
  description = "Buffer incoming events to the specified size, in MBs, before delivering it to the destination"
  type        = number
}

# Lambda
variable "cloudwatch_logs_retention_days" {
  default     = 14
  description = "Keep the Cloudwatch logs of the infrastructure (Lambdas & Kinesis Firehose) for this number of days."
  type        = number
}

variable "lambda_logs_verbose" {
  default     = false
  description = "Include debug information in the Lambdas processing logs."
  type        = bool
}

variable "python_version" {
  default     = "3.9"
  description = "AWS Lambda Python runtime version"
  type        = string
}

variable "secret" {
  default     = ""
  description = "Secret to be expected by the collector"
  sensitive   = true
  type        = string
}

# S3
variable "s3_lifecycle_configuration_rules" {
  type = list(object({
    enabled = optional(bool, true)
    id      = string

    abort_incomplete_multipart_upload_days = optional(number)

    # `filter_and` is the `and` configuration block inside the `filter` configuration.
    # This is the only place you should specify a prefix.
    filter_and = optional(object({
      object_size_greater_than = optional(number) # integer >= 0
      object_size_less_than    = optional(number) # integer >= 1
      prefix                   = optional(string)
      tags                     = optional(map(string), {})
    }))
    expiration = optional(object({
      date                         = optional(string) # string, RFC3339 time format, GMT
      days                         = optional(number) # integer > 0
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_expiration = optional(object({
      newer_noncurrent_versions = optional(number) # integer > 0
      noncurrent_days           = optional(number) # integer >= 0
    }))
    transition = optional(list(object({
      date          = optional(string) # string, RFC3339 time format, GMT
      days          = optional(number) # integer > 0
      storage_class = optional(string)
      # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    })), [])

    noncurrent_version_transition = optional(list(object({
      newer_noncurrent_versions = optional(number) # integer >= 0
      noncurrent_days           = optional(number) # integer >= 0
      storage_class             = optional(string)
      # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    })), [])
  }))
  default     = []
  description = "A list of lifecycle V2 rules for the S3 bucket where the audit trail events are stored. See example usage https://github.com/cloudposse/terraform-aws-s3-bucket or on AWS docs."
  nullable    = false
}
