# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get VPC
data "aws_vpc" "vpc" {
  id = var.networking_settings.vpc_id
}
