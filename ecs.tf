
module "ecs_cluster" {
  source = "github.com/binbashar/terraform-aws-ecs.git?ref=v5.11.4"

  cluster_name = var.cluster_name

  # Capacity providers definition
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 60
        base   = 1
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 40
      }
    }
  }

  services = {}

  #depends_on = [data.aws_nat_gateways.natgtw]

  tags = local.tags
}
