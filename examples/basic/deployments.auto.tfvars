deployment_settings = {
  task_definition_template_path = var.task_definition_template_path
  source_action = {
    name = "GitHub"
  }

  # Configuration for traffic routing:
  # - All at once deployment
  # - No interval between deployments
  # - 100% of traffic routed to new instances
  traffic_routing_config = {
    type       = "AllAtOnce"
    interval   = 1
    percentage = 100
  }

  # Configuration for deployment style:
  # - Blue/green deployment with traffic control
  deployment_style = {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # Configuration for minimum healthy hosts:
  # - 100% of traffic routed to new instances
  minimum_healthy_hosts = {
    type  = "HOST_COUNT"
    value = 1
  }

  # Configuration for blue/green deployment:
  # - Terminates blue instances 4 minutes after successful deployment
  # - Continues deployment if deployment ready timeout occurs
  blue_green_deployment_config = {
    terminate_blue_instances_on_deployment_success = {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 4
    }
    deployment_ready_option = {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  # Configuration for prod traffic route listener name in ALB
  # - This is the listener name for the prod traffic route
  # - The name is based on the listener name in the ALB module
  prod_traffic_route_listener_name = "http"

  # Bucket configuration for codepipeline
  bucket = {
    name                    = "flokzu-codepipeline"
    force_destroy           = false
    attach_policy           = false
    block_public_acls       = true
    block_public_policy     = true
    restrict_public_buckets = true
    versioning = {
      status     = true
      mfa_delete = false
    }
    kms_master_key_id = "alias/aws/s3"
    sse_algorithm     = "AES256"
    lifecycle_rule = [
      {
        id      = "delete-reports-1-day"
        enabled = true
        filter = {
          prefix = "reports/"
        }
        noncurrent_version_expiration = {
          days = 1
        }
        expiration = {
          days = 1
        }

      },
      {
        id      = "delete-prints-1-day"
        enabled = true
        filter = {
          prefix = "prints/"
        }
        noncurrent_version_expiration = {
          days = 1
        }
        expiration = {
          days = 1
        }
      }

    ]
  }

  # Notification configuration for codepipeline
  notification = {
    name                        = "codepipeline-notifications"
    create_topic_policy         = true
    enable_default_topic_policy = false
  }

}
