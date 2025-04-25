provider "aws" {
  region = "us-east-1"
}

module "collector" {
  source = "../.."

  namespace  = "mp"
  name       = "spacelift"
  attributes = ["audit-trail-events"]

  secret = "some-secret-to-protect-the-lambda-endpoint" # We recommend using a secret manager to store and reference this, such as SOPS.

  s3_lifecycle_configuration_rules = [{
    enabled = true
    id      = "spacelift-audit-trail-s3-rule"
    # 6 month retention with no transitions
    expiration = {
      days = 180
    }
    abort_incomplete_multipart_upload_days = null
    filter_and                             = null
    noncurrent_version_expiration          = null
    noncurrent_version_transition          = null
    transition                             = null
  }]
}
