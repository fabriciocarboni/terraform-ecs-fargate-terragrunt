/*
 * terragrunt.hcl
 * Handles ECS Terragrunt configuration
 */

locals {
  environment_config = read_terragrunt_config(find_in_parent_folders("environment_specific.hcl"))
  service            = "ecs"
  provider           = local.environment_config.locals.provider
  tag                = local.environment_config.locals.tag
  environment        = local.environment_config.locals.environment
  region             = local.environment_config.locals.region
  s3_bucket_name     = "${local.environment_config.locals.client}-terraform-state-${local.environment}-${local.service}"
  dynamodb_table     = "${local.environment_config.locals.client}-${local.environment}-${local.service}-lock-table"
}


#calls the specific module ECS in a external repo
terraform {
    source = "../../modules//aws_ecs"
}


# Indicate what region to deploy the resources into
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
    provider "${local.provider}" {
    region = "${local.region}"
  }
  EOF
}


remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "${local.s3_bucket_name}"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.region}"
    encrypt        = true
    dynamodb_table = "${local.dynamodb_table}"
  }
}

dependency "vpc" {
  config_path = "../aws_vpc"
}

dependency "alb" {
  config_path = "../aws_alb"
}

# Receive these inputs from dependencies (VPC and ALB)
inputs = {
  aws_region       = "${local.region}"
  vpc_id           = dependency.vpc.outputs.vpc_id
  private_subnets  = dependency.vpc.outputs.private_subnets
  alb_tg_arn       = dependency.alb.outputs.alb_tg_arn
}