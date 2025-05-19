module "ecs_infra" {
  source = "../../"

  region                        = "us-east-1"
  cluster_name                  = "ecs-cluster"
  task_definition_template_path = "./task-definition.json"

  alb_settings                  = var.alb_settings
  services                      = var.services
  networking_settings           = var.networking_settings
  security_settings             = var.security_settings
  deployment_settings           = var.deployment_settings
  turn_off_services             = var.turn_off_services
  turn_off_on_services_schedule = var.turn_off_on_services_schedule
  tags                          = var.tags
}
