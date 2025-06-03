locals {
  # create listener 
  listeners = {
    for key, value in var.alb_settings.listeners : key => {
      port           = value.port
      protocol       = value.protocol
      rules          = local.listener_rules
      fixed_response = value.fixed_response
    }
  }

  listener_rules = { for key, value in var.services : key => {
    actions = [
      {
        type             = "forward"
        target_group_key = "${key}_blue"
      }
    ]
    conditions = [{
      path_pattern = {
        values = ["/${value.name}/*"]
      }
    }]
    }
  }
  target_groups_blue = {
    for key, value in var.services :
    "${key}_blue" => {
      name        = "${key}-blue"
      protocol    = value.application_protocol
      port        = value.application_port
      target_type = "ip"

      health_check = value.application_health_check
      # ECS handles the attachment
      create_attachment = false
    }
  }
  target_groups_green = {
    for key, value in var.services :
    "${key}_green" => {
      name        = "${key}-green"
      protocol    = value.application_protocol
      port        = value.application_port
      target_type = "ip"

      health_check = value.application_health_check
      # ECS handles the attachment
      create_attachment = false
    }
  }
  target_groups = merge(local.target_groups_blue, local.target_groups_green)
}


##
## ECS ALB
##
module "alb_ecs" {
  source = "github.com/binbashar/terraform-aws-alb.git?ref=v9.9.0"
  # General settings
  name                       = var.alb_settings.name
  load_balancer_type         = var.alb_settings.load_balancer_type
  internal                   = var.alb_settings.internal
  enable_deletion_protection = var.alb_settings.enable_deletion_protection
  listeners                  = local.listeners
  target_groups              = local.target_groups
  tags                       = var.alb_settings.tags
  # Networking settings
  vpc_id                       = var.networking_settings.vpc_id
  subnets                      = var.networking_settings.alb_subnets
  security_group_ingress_rules = var.alb_settings.security_group_ingress_rules
  security_group_egress_rules  = var.alb_settings.security_group_egress_rules
}
