# Indicate where to source the terraform module from.
locals {
  environment_config = read_terragrunt_config("environment_specific.hcl")
  environment_name   = local.environment_config.locals.environment
  region             = local.environment_config.locals.region
  provider           = local.environment_config.locals.provider
}




#Indicate what region to deploy the resources into
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  provider "aws" {
  region = "${local.region}"
}
EOF
}



