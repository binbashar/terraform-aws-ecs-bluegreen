
module "ecs_cluster" {
  source = "github.com/binbashar/terraform-aws-ecs.git?ref=v5.11.4"

  cluster_name = var.ecs_cluster_settings.name
  # Capacity providers definition
  fargate_capacity_providers = var.ecs_cluster_settings.fargate_capacity_providers

  services = {}
  tags     = var.tags
}
