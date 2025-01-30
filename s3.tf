
module "audit_trail_s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.10.0"

  name                = module.this.id
  s3_object_ownership = "BucketOwnerEnforced"

  lifecycle_configuration_rules = var.s3_lifecycle_configuration_rules

  privileged_principal_arns = [{
    (aws_iam_role.stream.arn) = ["*"] # Only allow the Kinesis Stream role to bucket
  }]
  privileged_principal_actions = [
    "s3:PutObject",
    "s3:GetObject",
    "s3:ListBucket"
  ]
}
