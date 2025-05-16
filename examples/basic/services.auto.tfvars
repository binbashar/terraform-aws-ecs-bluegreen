
#   Backend Services Configuration Details   #
##############################################

services = {
  "bi-service" = {
    name                           = "biservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-bi-service-stg"
    git_repository = {
      name   = "gobpm/bi-service"
      branch = "development"
    }
    alarms = {}

    deployment_controller = {
      type = "CODE_DEPLOY"
    }

    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }

    task_iam_role_name = "bi-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "bi-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/biservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      bi-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-bi-service-stg:fkzu-4a22e84"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "bi-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment = [
          {
            name  = "producto"
            value = "922433cd25ab508f3f67605b795eeb2e"
          },
          {
            name  = "ambiente"
            value = "prep"
          },
          {
            name  = "DRAGONFLY_AMBIENTE"
            value = "test"
          },
          {
            name  = "JWT_BASE64"
            value = "YkV6JVI1MmNFZ0U5ZjY3JFBaI3BFIVNPVw=="
          },
          {
            name  = "jwt.base64"
            value = "YkV6JVI1MmNFZ0U5ZjY3JFBaI3BFIVNPVw=="
          },
          {
            name  = "database.engine.name"
            value = "POSTGRESQL"
          },
          {
            name  = "SPRING_DATASOURCE_HIKARI_MAXIMUMPOOLSIZE"
            value = "3"
          },
          {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:postgresql://172.31.136.157:5432/bintelligence"
          },
          {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "flokzu"
          },
          {
            name  = "SPRING_DATASOURCE_PASSWORD"
            value = "En48RJs5ajuqcb3wd8e"
          },
          {
            name  = "bi.publish.name"
            value = "fz-bi-queue-prep"
          },
          {
            name  = "send.mail.publish.name"
            value = "fz-mail-queue-prep"
          },
          {
            name  = "service.dms.url"
            value = "http://besvcs.flokzu.intranet:8080/bpmsdmsservice/rest"
          },
          {
            name  = "service.engine.url"
            value = "http://besvcs.flokzu.intranet:8080/bpmscoreengine/rest"
          },
          {
            name  = "service.tenant.url"
            value = "http://besvcs.flokzu.intranet:8080/bpmstenantservice/rest"
          },
          {
            name  = "amazon_queue_region"
            value = "us-east-1"
          },
          {
            name  = "DRAGONFLY_AMBIENTE"
            value = "prep"
          }

        ]
        secrets = [
          {
            name      = "DB_PASSWORD"
            valueFrom = "arn:aws:secretsmanager:us-east-1:221082167632:secret:/flokzu-db/administrator-QEXiVw:password::"
          }
        ]
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "wildfly-service" = {
    name                           = "bpmscoreengine"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-wildfly-stg"
    git_repository = {
      name   = "gobpm/wildfly-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }

    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }

    task_iam_role_name = "wildfly-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "wildfly-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      wildfly-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-wildfly-stg:fkzu-36868bf"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "wildfly-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "dms-service" = {
    name                           = "dmsservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-dms-service-stg"
    git_repository = {
      name   = "gobpm/bpms-dms-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }

    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }

    task_iam_role_name = "dms-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "dms-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/dmsservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      dms-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-dms-service-stg:fkzu-135774d"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "dms-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "elasticsearch-service" = {
    name                           = "elasticsearchservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-elasticsearch-service-stg"
    git_repository = {
      name   = "gobpm/bpms-search-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }

    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }

    task_iam_role_name = "elasticsearch-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "elasticsearch-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/elasticsearchservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      elasticsearch-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-elasticsearch-service-stg:fkzu-22424d2"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "elasticsearch-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "history-service" = {
    name                           = "historyservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-history-service-stg"
    git_repository = {
      name   = "gobpm/bpms-history-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }

    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }

    task_iam_role_name = "history-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "history-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/historyservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      history-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-history-service-stg:fkzu-46b72a3"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "history-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "impresion-service" = {
    name                           = "impresionservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-impresion-service-stg"
    git_repository = {
      name   = "gobpm/dragonfly-impresion-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }
    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }
    task_iam_role_name = "impresion-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "impresion-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/impresionservice/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      impresion-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-impresion-service-stg:fkzu-f71dc14"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "impresion-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "integration-service" = {
    name                           = "integrationservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-integration-service-stg"
    git_repository = {
      name   = "gobpm/integration-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }
    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }
    task_iam_role_name = "integration-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "integration-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/integrationservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      integration-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-integration-service-stg:fkzu-a48048a"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "integration-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "mail-service" = {
    name                           = "mailservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-mail-service-stg"
    git_repository = {
      name   = "gobpm/mail-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }
    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }
    task_iam_role_name = "mail-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "mail-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/mailservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      mail-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-mail-service-stg:fkzu-d0dbaea"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "mail-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "notification-service" = {
    name                           = "notificationservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-notification-service-stg"
    git_repository = {
      name   = "gobpm/bpms-notification-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }
    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }
    task_iam_role_name = "notification-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "notification-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/notificationservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      notification-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-notification-service-stg:fkzu-b03f3a1"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "notification-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "process-instance-service" = {
    name                           = "processinstanceservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-processinstance-service-stg"
    git_repository = {
      name   = "gobpm/process-instance-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }
    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }
    task_iam_role_name = "process-instance-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "process-instance-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/processinstanceservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      process-instance-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-processinstance-service-stg:fkzu-3631e19"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "process-instance-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "report-service" = {
    name                           = "reportservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-report-service-stg"
    git_repository = {
      name   = "gobpm/bpms-report-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }
    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }
    task_iam_role_name = "report-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "report-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/reportservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      report-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-report-service-stg:fkzu-65fc8fc"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "report-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "usermanagement-service" = {
    name                           = "usermanagementservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-usermanagement-service-stg"
    git_repository = {
      name   = "gobpm/dragonfly-user-management-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }
    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }
    task_iam_role_name = "usermanagement-backend-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "usermanagement-backend-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port     = 8080
    application_protocol = "HTTP"
    application_health_check = {
      path                = "/usermanagementservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      usermanagement-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-usermanagement-service-stg:fkzu-a060176"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "usermanagement-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
  "userdatabase-service" = {
    name                           = "userdatabaseservice"
    ignore_task_definition_changes = true
    ecr_repository                 = "fz-userdatabase-service-stg"
    git_repository = {
      name   = "gobpm/bpms-userdatabase-service"
      branch = "development"
    }
    alarms = {}
    deployment_controller = {
      type = "CODE_DEPLOY"
    }
    autoscaling_configuration = {
      enable       = true
      min_capacity = 1
      max_capacity = 1
    }
    task_iam_role_name = "userdatabase-service-task-role"
    tasks_iam_role_statements = [
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "km:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      }
    ]
    create_task_definition  = true
    task_exec_iam_role_name = "userdatabase-service-task-exec"
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:221082167632:secret:*"
    ]
    task_exec_iam_statements = [
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetSecretValue"
        ]
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        resources = ["*"]
      }
    ]

    application_port      = 8080
    application_test_port = 8081
    application_protocol  = "HTTP"
    application_health_check = {
      path                = "/userdatabaseservice/rest/actuator/health"
      interval            = 30
      timeout             = 20
      healthy_threshold   = 2
      unhealthy_threshold = 4
      port                = 8080
      protocol            = "HTTP"
    }

    container_definitions = {
      userdatabase-service = {
        cpu                      = 512
        memory                   = 1024
        image                    = "221082167632.dkr.ecr.us-east-1.amazonaws.com/fz-userdatabase-service-stg:fkzu-4e74801"
        readonly_root_filesystem = false
        port_mappings = [
          {
            name          = "userdatabase-service"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }
        ]
        environment                            = []
        cloudwatch_log_group_retention_in_days = 3
      }
    }
    tags         = {}
    service_tags = {}
  }
}

# Security Group Configuration for Backend Services 
# there pre-defined rules for http-80-tcp, http-8080-tcp, https-443-tcp, https-8443-tcp
# you can add more rules by adding the rule name to the ingress_rules list
# e.g. ingress_rules = ["http-80-tcp", "http-8080-tcp", "https-443-tcp", "https-8443-tcp", "custom-rule"]
# repository with rules information: https://github.com/binbashar/terraform-aws-security-group/blob/master/rules.tf


# Security Settings
security_settings = {
  vpc_id              = "vpc-0577524a0e38786ea"
  security_group_name = "backend"
  description         = "Security Group for Backend Services"
  security_group_rules = [
    "http-80-tcp",
    "http-8080-tcp",
    "https-443-tcp",
    "https-8443-tcp"
  ]
}

# Schedule Configuration
turn_off_services = false
turn_off_on_services_schedule = {
  schedule_off_expression = "cron(0 23 ? * MON,TUE,WED,THUR,FRI *)"
  schedule_on_expression  = "cron(0 0 ? * MON,TUE,WED,THUR,FRI *)"
}
