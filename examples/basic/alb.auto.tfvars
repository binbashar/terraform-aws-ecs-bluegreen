alb_settings = {
  name                       = "backend-alb"
  load_balancer_type         = "application"
  internal                   = true
  enable_deletion_protection = true
  vpc_id                     = "vpc-0577524a0e38786ea"
  subnets                    = ["subnet-0577524a0e38786ea", "subnet-0577524a0e38786ea", "subnet-0577524a0e38786ea"]
  security_group_ingress_rules = {
    http = {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
      cidr_ipv4 = "0.0.0.0/0"
    }
    http_8080 = {
      from_port = 8080
      to_port   = 8080
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
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  listeners = {
    # Forwards HTTP traffic to the ecs-apps backend service based path  
    http = {
      port     = 8080
      protocol = "HTTP"
      # Default action
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }

    }
    http_test = {
      port     = 8081
      protocol = "HTTP"
      # Default action
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  }
  tags = {
    Environment = "dev"
    Project     = "backend"
  }
}
