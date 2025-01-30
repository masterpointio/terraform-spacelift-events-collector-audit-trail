# trunk-ignore(trivy/AVD-AWS-0143): False positive
# trunk-ignore(trivy/AVD-AWS-0132): False positive
provider "aws" {
  region = "us-east-1"
}

module "collector" {
  source = "../.."

  namespace  = "mp"
  name       = "spacelift"
  attributes = ["audit-trail-events"]

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
