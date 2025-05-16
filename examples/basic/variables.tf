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
  type        = any
  description = "Networking Settings"
  default     = {}
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
  default     = {}
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

variable "turn_off_services" {
  type        = bool
  description = "Turn off services ecs cluster"
  default     = false
}

variable "turn_off_on_services_schedule" {
  type        = any
  description = "Turn off and on services ecs cluster schedule"
  default     = {}
}
