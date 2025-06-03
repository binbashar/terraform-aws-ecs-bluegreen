resource "aws_scheduler_schedule" "turn_off_services" {
  for_each    = var.turn_off_services ? var.services : {}
  name        = "turn-off-${each.key}"
  description = "Turn off ${each.key} service"

  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.turn_off_on_services_schedule.schedule_off_expression

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.scheduler_role[each.key].arn

    input = jsonencode({
      Cluster      = module.ecs_cluster.cluster_name
      Service      = each.key
      DesiredCount = 0
    })
  }
}

resource "aws_scheduler_schedule" "turn_on_services" {
  for_each    = var.turn_off_services ? var.services : {}
  name        = "turn-on-${each.key}"
  description = "Turn on ${each.key} service"

  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.turn_off_on_services_schedule.schedule_on_expression

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.scheduler_role[each.key].arn

    input = jsonencode({
      Cluster      = module.ecs_cluster.cluster_name
      Service      = each.key
      DesiredCount = 1
    })

  }
}


##### Role for Scheduler #####
data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scheduler_role" {
  for_each           = var.services
  name               = "${each.key}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

resource "aws_iam_role_policy" "scheduler_role_policy" {
  for_each = var.services
  name     = "${each.key}-scheduler-role-policy"
  role     = aws_iam_role.scheduler_role[each.key].id
  policy   = data.aws_iam_policy_document.scheduler_role_policy[each.key].json
}

data "aws_iam_policy_document" "scheduler_role_policy" {
  for_each = var.services
  statement {
    effect = "Allow"

    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]

    resources = ["arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:service/${module.ecs_cluster.cluster_name}/${each.key}"]
  }
}
