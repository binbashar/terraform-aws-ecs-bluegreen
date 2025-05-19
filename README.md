# Terraform AWS ECS Blue/Green Deployment Module

This Terraform module provides a complete solution for deploying and managing ECS services with blue/green deployment capabilities on AWS. It includes ALB configuration, service definitions, and deployment settings with support for CodeDeploy integration.

## Features

- ECS Cluster and Service Management
- Application Load Balancer (ALB) Configuration
- Blue/Green Deployment Support
- Auto Scaling Configuration
- IAM Role and Policy Management
- CloudWatch Alarms and Logging
- CodeDeploy Integration
- S3 Bucket for CodePipeline
- SNS Notifications
- Service Scheduling (Auto Start/Stop)
- Git Service Integration for CodePipeline

## Quick Start

```hcl
module "ecs_infra" {
  source = "path/to/module"

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
```

## Detailed Configuration

### ALB Settings

```hcl
alb_settings = {
  name                       = "backend-alb"
  load_balancer_type         = "application"
  internal                   = true
  enable_deletion_protection = true
  vpc_id                     = "vpc-xxxxx"
  subnets                    = ["subnet-xxxxx", "subnet-yyyyy", "subnet-zzzzz"]
  
  security_group_ingress_rules = {
    http = {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
      cidr_ipv4 = "0.0.0.0/0"
    }
    https = {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
      cidr_ipv4 = "0.0.0.0/0"
    }
  }
  
  listeners = {
    http = {
      port     = 8080
      protocol = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  }
}
```

### Service Configuration

```hcl
services = {
  "my-service" = {
    name                           = "my-service"
    ignore_task_definition_changes = true
    ecr_repository                 = "my-service-repo"
    
    deployment_controller = {
      type = "CODE_DEPLOY"
    }

    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      my-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "123456789.dkr.ecr.region.amazonaws.com/my-service:latest"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "my-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment = [
          {
            name  = "ENVIRONMENT"
            value = "production"
          }
        ]
        cloudwatch_log_group_retention_in_days = 3
      }
    }
  }
}
```

### Deployment Settings

```hcl
deployment_settings = {
  traffic_routing_config = {
    type       = "AllAtOnce"
    interval   = 1
    percentage = 100
  }

  deployment_style = {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config = {
    terminate_blue_instances_on_deployment_success = {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 4
    }
    deployment_ready_option = {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  bucket = {
    name                    = "my-codepipeline-bucket"
    force_destroy           = false
    block_public_acls       = true
    block_public_policy     = true
    restrict_public_buckets = true
    versioning = {
      status     = true
      mfa_delete = false
    }
  }
}
```

### Service Scheduling

```hcl
# Enable service scheduling
turn_off_services = true

# Configure schedule for service start/stop
turn_off_on_services_schedule = {
  schedule_off_expression = "cron(0 23 ? * MON,TUE,WED,THUR,FRI *)"  # Turn off at 11 PM on weekdays
  schedule_on_expression  = "cron(0 0 ? * MON,TUE,WED,THUR,FRI *)"   # Turn on at 12 AM on weekdays
}
```

### Git Service Integration

```hcl
git_service = {
  connection_name = "github"
  type           = "github"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.0 |

## Prerequisites

- AWS Account and credentials configured
- ECS Cluster
- VPC with public and private subnets
- ECR Repository for container images
- Git repository for source code

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region | `string` | n/a | yes |
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| task_definition_template_path | Path to the task definition template | `string` | n/a | yes |
| alb_settings | ALB configuration settings | `map` | `{}` | no |
| services | ECS services configuration | `map` | `{}` | no |
| networking_settings | Networking configuration settings | `map` | `{}` | no |
| security_settings | Security configuration settings | `map` | `{}` | no |
| deployment_settings | Deployment configuration settings | `map` | `{}` | no |
| git_service | Git service configuration for CodePipeline | `object` | `{connection_name = "github", type = "github"}` | no |
| turn_off_services | Enable/disable service scheduling | `bool` | `false` | no |
| turn_off_on_services_schedule | Schedule configuration for service start/stop | `object` | See example | no |
| tags | Tags for the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | Name of the ECS cluster |
| services | Details of the ECS services |
| security_groups | Security groups associated with the services |
| turn_off_on_services_schedule | Schedule configuration for service start/stop |

## Examples

Check the `examples/basic` directory for a complete working example of how to use this module.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
