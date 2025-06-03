#################################################################
#                                                               #
#  This files is used for deployment of the ECS applications    #
#                                                               #
#################################################################

resource "aws_codepipeline" "ecs_apps" {
  for_each = var.services
  name     = "ecs-service-${each.key}"
  role_arn = aws_iam_role.codepipeline[each.key].arn

  pipeline_type = "V2"

  artifact_store {
    location = module.codepipeline_bucket.s3_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = var.deployment_settings.source_action.name
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.git_connection.arn
        FullRepositoryId = each.value.git_repository.name
        BranchName       = each.value.git_repository.branch
      }
    }

    action {
      name             = "Image"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["service_image"]

      configuration = {
        RepositoryName = each.value.ecr_repository
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["service_image", "source_output"]

      configuration = {
        AppSpecTemplateArtifact        = "source_output"
        AppSpecTemplatePath            = "appspec.yml"
        TaskDefinitionTemplateArtifact = "source_output"
        TaskDefinitionTemplatePath     = var.deployment_settings.task_definition_template_path
        ApplicationName                = "ecs-service-${each.key}"
        DeploymentGroupName            = "ecs-service-${each.key}"
        Image1ArtifactName             = "service_image"
        Image1ContainerName            = "IMAGE1_NAME"

      }
    }
  }

  tags = var.tags

}


module "ecs_codedeploy" {
  for_each = var.services
  source   = "github.com/binbashar/terraform-aws-code-deploy.git?ref=0.2.3"

  name = "ecs-service-${each.key}"

  traffic_routing_config = {
    type       = var.deployment_settings.traffic_routing_config.type
    interval   = var.deployment_settings.traffic_routing_config.interval
    percentage = var.deployment_settings.traffic_routing_config.percentage
  }

  deployment_style = var.deployment_settings.deployment_style

  minimum_healthy_hosts = var.deployment_settings.minimum_healthy_hosts

  blue_green_deployment_config = {
    terminate_blue_instances_on_deployment_success = {
      action                           = var.deployment_settings.blue_green_deployment_config.terminate_blue_instances_on_deployment_success.action
      termination_wait_time_in_minutes = var.deployment_settings.blue_green_deployment_config.terminate_blue_instances_on_deployment_success.termination_wait_time_in_minutes
    }
    deployment_ready_option = {
      action_on_timeout = var.deployment_settings.blue_green_deployment_config.deployment_ready_option.action_on_timeout
    }
  }

  ecs_service = [
    {
      cluster_name = module.ecs_cluster.cluster_name
      service_name = module.ecs_services[each.key].name
    }
  ]

  load_balancer_info = {
    target_group_pair_info = {
      prod_traffic_route = {
        listener_arns = [
          module.alb_ecs.listeners[var.deployment_settings.prod_traffic_route_listener_name].arn
        ]
      }

      blue_target_group = {
        name = module.alb_ecs.target_groups["${each.key}_blue"].name
      }

      green_target_group = {
        name = module.alb_ecs.target_groups["${each.key}_green"].name
      }
    }
  }
}


######################################
#      S3 Bucket for CodeDeploy      #
######################################
module "codepipeline_bucket" {
  source = "github.com/binbashar/terraform-aws-s3-bucket.git?ref=v4.2.2"

  bucket        = var.deployment_settings.bucket.name
  force_destroy = var.deployment_settings.bucket.force_destroy

  attach_policy = var.deployment_settings.bucket.attach_policy

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.deployment_settings.bucket.kms_master_key_id
        sse_algorithm     = var.deployment_settings.bucket.sse_algorithm
      }
    }
  }

  versioning = var.deployment_settings.bucket.versioning

  lifecycle_rule = var.deployment_settings.bucket.lifecycle_rule

  # S3 bucket-level Public Access Block configuration
  block_public_acls   = var.deployment_settings.bucket.block_public_acls
  block_public_policy = var.deployment_settings.bucket.block_public_policy
  #ignore_public_acls      = true
  restrict_public_buckets = var.deployment_settings.bucket.restrict_public_buckets

  tags = var.tags
}

######################################
#      IAM Role for Codepipeline     #
######################################

data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_policy" {
  for_each = var.services
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]

    resources = [
      module.codepipeline_bucket.s3_bucket_arn,
      "${module.codepipeline_bucket.s3_bucket_arn}/*"
    ]
  }
  statement {
    sid = "codedeploy"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
  }
  statement {
    sid = "ecr"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = ["*"]
  }
  statement {
    sid = "ecsTask"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTasks",
      "ecs:DescribeTasks"
    ]
    resources = ["*"]
  }
  statement {
    sid = "ecsCluster"
    actions = [
      "ecs:ListClusters",
      "ecs:DescribeClusters"
    ]
    resources = [module.ecs_cluster.cluster_arn]
  }
  statement {
    sid = "ecsService"
    actions = [
      "ecs:ListServices",
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]
    resources = [module.ecs_services[each.key].id]
  }
  statement {
    sid = "codestar"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["*"]
  }
  statement {
    sid = "kms"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncrypt*",
      "kms:DescribeKey"
    ]
    resources = [var.deployment_settings.bucket.kms_master_key_id]
  }
  statement {
    sid = "iam"
    actions = [
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::*:role/*"]
  }

}

resource "aws_iam_role" "codepipeline" {
  for_each           = var.services
  name               = "codepipeline-role-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

resource "aws_iam_policy" "codepipeline" {
  for_each    = var.services
  name        = "codepipeline-policy-${each.key}"
  description = "Codepipeline policy for ${each.key}"
  policy      = data.aws_iam_policy_document.codepipeline_policy[each.key].json
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  for_each   = var.services
  role       = aws_iam_role.codepipeline[each.key].name
  policy_arn = aws_iam_policy.codepipeline[each.key].arn
}

######################################
#      EventBridge Rule              #
######################################

data "aws_iam_policy_document" "ecr_image_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "ecr_image_policy" {
  for_each = var.services
  statement {
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = [aws_codepipeline.ecs_apps[each.key].arn]
  }
}

resource "aws_iam_role" "ecr_image" {
  for_each           = var.services
  name               = "ecr-push-image-role-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.ecr_image_assume_role_policy.json
}

resource "aws_iam_policy" "ecr_image" {
  for_each    = var.services
  name        = "ecr-image-policy-${each.key}"
  description = "ECR image policy for ${each.key}"
  policy      = data.aws_iam_policy_document.ecr_image_policy[each.key].json
}

resource "aws_iam_role_policy_attachment" "ecr_image" {
  for_each   = var.services
  role       = aws_iam_role.ecr_image[each.key].name
  policy_arn = aws_iam_policy.ecr_image[each.key].arn
}

resource "aws_cloudwatch_event_rule" "ecr_image_push" {
  for_each    = var.services
  name        = "ecr-image-push-${each.key}"
  description = "ECR image push event rule for ${each.key}"
  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type     = ["PUSH"],
      image-tag       = [{ "prefix" : var.deployment_settings.image_tag_prefix }],
      repository-name = [each.value.ecr_repository],
      result          = ["SUCCESS"]
    }
  })

  role_arn = aws_iam_role.ecr_image[each.key].arn

  tags = var.tags
}

# Event rule to trigger CodePipeline when an image is pushed to ECR
# This rule monitors ECR image pushes with specified tag prefix and triggers the corresponding pipeline

resource "aws_cloudwatch_event_target" "codepipeline_trigger" {
  for_each  = var.services
  rule      = aws_cloudwatch_event_rule.ecr_image_push[each.key].name
  target_id = "codepipeline-trigger-${each.key}"
  arn       = aws_codepipeline.ecs_apps[each.key].arn
  role_arn  = aws_iam_role.ecr_image[each.key].arn

  input_transformer {
    input_paths = {
      revisionValue = "$.detail.image-digest"
    }
    input_template = <<EOF
{
    "sourceRevisions":[ 
       {
        "actionName": "Image",
        "revisionType": "IMAGE_DIGEST",
        "revisionValue": "<revisionValue>"
       }
    ]
}
EOF
  }
}


######################################
#   Codepipeline Notification        #
######################################

module "codepipeline_notifications" {
  for_each = var.services
  source   = "terraform-aws-modules/sns/aws"
  version  = "v6.1.2"

  name                        = "${each.key}-${var.deployment_settings.notification.name}"
  create_topic_policy         = var.deployment_settings.notification.create_topic_policy
  enable_default_topic_policy = var.deployment_settings.notification.enable_default_topic_policy
  topic_policy_statements = {
    codepipeline = {
      actions = [
        "sns:publish"
      ]
      resources = [
        "*"
      ]
      principals = [{
        type        = "Service"
        identifiers = ["codepipeline.amazonaws.com"]
      }]
    }

  }

  # KMS Key
  kms_master_key_id = var.deployment_settings.bucket.kms_master_key_id

  # Tags
  tags = var.tags
}


#######################################
# Git Connection                     #
#######################################

resource "aws_codestarconnections_connection" "git_connection" {
  name          = var.git_service.connection_name
  provider_type = var.git_service.type
  tags          = var.tags
}
