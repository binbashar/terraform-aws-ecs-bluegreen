data "aws_caller_identity" "current" {}

locals {
  environment = replace("dev", "apps-", "")
  name        = "apps-${local.environment}"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  # Get Network Configuration
  networking_settings = {
    vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
    alb_subnets     = data.terraform_remote_state.vpc.outputs.private_subnets
    service_subnets = data.terraform_remote_state.vpc.outputs.private_subnets
  }
}
