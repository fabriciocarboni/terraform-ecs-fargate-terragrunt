#Environment specific propeties
locals {
    client         = "any-client"
    environment    = "staging"
    tag            = "v0.0.1"
    provider       = "aws"
    region         = "us-east-1"
    azs            = ["us-east-1a", "us-east-1b"]
    s3_bucket_name = "${local.client}-terraform-state-${local.environment}"
    dynamodb_table = "${local.client}-${local.environment}-lock-table"
}

