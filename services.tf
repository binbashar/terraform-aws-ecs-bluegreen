###########################################
#     Create Services  (ECS)              #
###########################################

module "security_group" {
  source      = "github.com/binbashar/terraform-aws-security-group?ref=v5.3.0"
  name        = var.security_settings.security_group_name
  description = var.security_settings.description
  vpc_id      = data.aws_vpc.vpc.id

  # Default CIDR Blocks
  ingress_cidr_blocks = [data.aws_vpc.vpc.cidr_block]

  # Open for all CIDRs defined in ingress_cidr_blocks
  ingress_rules = var.security_settings.security_group_rules
  egress_rules  = ["all-all"]

  tags = local.tags
}

module "services" {
  for_each    = var.services
  source      = "github.com/binbashar/terraform-aws-ecs.git//modules/service?ref=v5.12.0"
  name        = each.key
  cluster_arn = module.ecs_cluster.cluster_arn

  # Service Configuration
  ignore_task_definition_changes = true
  alarms                         = each.value.alarms
  deployment_controller          = each.value.deployment_controller

  # Autoscaling Configuration
  enable_autoscaling       = each.value.autoscaling_configuration.enable
  autoscaling_min_capacity = each.value.autoscaling_configuration.min_capacity
  autoscaling_max_capacity = each.value.autoscaling_configuration.max_capacity

  # Network Configuration
  create_security_group = false
  security_group_ids    = [module.security_group.security_group_id]
  subnet_ids            = var.networking_settings.private_subnets
  load_balancer = {
    service = {
      target_group_arn = var.alb_settings.target_group_blue_arn
      container_name   = each.key
      container_port   = each.value.application_port
    }
  }

  # Task - IAM Role Configuration
  tasks_iam_role_name            = each.value.task_iam_role_name
  tasks_iam_role_use_name_prefix = false
  tasks_iam_role_statements      = each.value.tasks_iam_role_statements

  # Task Definition Configuration
  create_task_definition = each.value.create_task_definition
  # Task Execution - IAM Role Configuration
  task_exec_secret_arns              = each.value.task_exec_secret_arns
  task_exec_iam_role_use_name_prefix = false
  task_exec_iam_role_name            = each.value.task_exec_iam_role_name
  task_exec_iam_statements           = each.value.task_exec_iam_statements
  container_definitions              = each.value.container_definitions

  # Tags
  service_tags = each.value.tags
  tags         = each.value.tags
}

