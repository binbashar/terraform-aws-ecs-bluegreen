variable "ecs_cluster_settings" {
  type = object({
    name = string
    fargate_capacity_providers = object({
      FARGATE = object({
        default_capacity_provider_strategy = object({
          weight = number
          base   = number
        })
      })
      FARGATE_SPOT = object({
        default_capacity_provider_strategy = object({
          weight = number
          base   = number
        })
      })
    })
  })
  description = "ECS Cluster Settings"
  default = {
    name = "ecs-cluster"
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
          base   = 0
        }
      }
    }
  }
}

variable "alb_settings" {
  type        = any
  description = "ALB Settings"
  default     = {}
}

variable "services" {
  type        = any
  description = "ECS Backend Services Configuration Details"
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "networking_settings" {
  type = object({
    vpc_id          = string
    service_subnets = list(string)
    alb_subnets     = list(string)
  })
  description = "Network configuration settings including VPC ID and subnet lists for services and ALB"
}

variable "security_settings" {
  type        = any
  description = "Security Settings"
  default     = {}
}

variable "deployment_settings" {
  type        = any
  description = "Deployment Settings"
  default     = {}
}

variable "git_service" {
  type = object({
    connection_name = string
    type            = string
  })
  description = "Git Service Configuration for CodePipeline"
  default = {
    connection_name = "github"
    type            = "github"
  }
}

variable "turn_off_services" {
  type        = bool
  description = "Turn off services ecs cluster"
  default     = false
}

variable "turn_off_on_services_schedule" {
  type = object({
    schedule_off_expression = string
    schedule_on_expression  = string
  })
  description = "Turn off and on services ecs cluster schedule"
  default = {
    schedule_off_expression = "cron(0 23 ? * MON,TUE,WED,THUR,FRI *)"
    schedule_on_expression  = "cron(0 0 ? * MON,TUE,WED,THUR,FRI *)"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
  default     = {}
}

variable "task_definition_template_path" {
  type        = string
  description = "Path to the task definition template"
}

