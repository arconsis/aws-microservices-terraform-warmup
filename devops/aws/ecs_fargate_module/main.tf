provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = var.aws_region
}

################################################################################
# ECS Tasks Execution IAM
################################################################################
# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

################################################################################
# VPC Flow Logs IAM
################################################################################
resource "aws_iam_role" "vpc_flow_cloudwatch_logs_role" {
  name               = "vpc-flow-cloudwatch-logs-role"
  assume_role_policy = file("../common/templates/policies/vpc_flow_cloudwatch_logs_role.json.tpl")
}

resource "aws_iam_role_policy" "vpc_flow_cloudwatch_logs_policy" {
  name = "vpc-flow-cloudwatch-logs-policy"
  role = aws_iam_role.vpc_flow_cloudwatch_logs_role.id
  policy = file("../common/templates/policies/vpc_flow_cloudwatch_logs_policy.json.tpl")
}

module "networking" {
	source               = "../modules/network"
  create_vpc           = var.create_vpc
  create_igw           = var.create_igw
  single_nat_gateway   = var.single_nat_gateway
  enable_nat_gateway   = var.enable_nat_gateway
  region               = var.aws_region
  vpc_name             = var.vpc_name
  cidr_block           = var.cidr_block
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "alb_sg" {
  source                    = "../modules/security"
  create_vpc                = var.create_vpc
  create_sg                 = true
  sg_name                   = "load-balancer-security-group"
  description               = "controls access to the ALB"
  rule_ingress_description  = "controls access to the ALB"
  rule_egress_description   = "allow all outbound"
  vpc_id                    = module.networking.vpc_id
  ingress_cidr_blocks       = ["0.0.0.0/0"]
  ingress_from_port         = 80
  ingress_to_port           = 80
  ingress_protocol          = "tcp"
  egress_cidr_blocks        = ["0.0.0.0/0"]
  egress_from_port          = 0
  egress_to_port            = 0
  egress_protocol           = "-1"
}

module "ecs_tasks_sg" {
  source                            = "../modules/security"
  create_vpc                        = var.create_vpc
  create_sg                         = true
  sg_name                           = "ecs-tasks-security-group"
  description                       = "controls access to the ECS tasks"
  rule_ingress_description          = "allow inbound access from the ALB only"
  rule_egress_description           = "allow all outbound"
  vpc_id                            = module.networking.vpc_id
  ingress_cidr_blocks               = null
  ingress_from_port                 = 0
  ingress_to_port                   = 0
  ingress_protocol                  = "-1"
  ingress_source_security_group_id  = module.alb_sg.security_group_id
  egress_cidr_blocks                = ["0.0.0.0/0"]
  egress_from_port                  = 0
  egress_to_port                    = 0
  egress_protocol                   = "-1"
}

module "private_ecs_tasks_sg" {
  source                            = "../modules/security"
  create_vpc                        = var.create_vpc
  create_sg                         = true
  sg_name                           = "ecs-private-tasks-security-group"
  description                       = "controls access to the private ECS tasks (not internet facing)"
  rule_ingress_description          = "allow inbound access only from resources in VPC"
  rule_egress_description           = "allow all outbound"
  vpc_id                            = module.networking.vpc_id
  ingress_cidr_blocks               = [var.cidr_block]
  ingress_from_port                 = 0
  ingress_to_port                   = 0
  ingress_protocol                  = "-1"
  egress_cidr_blocks                = ["0.0.0.0/0"]
  egress_from_port                  = 0
  egress_to_port                    = 0
  egress_protocol                   = "-1"
}

module "public_alb" {
	source             = "../modules/alb"
  create_alb         = var.create_alb
  load_balancer_type = "application"
  alb_name           = "main-ecs-lb"
  internal           = false
  vpc_id             = module.networking.vpc_id
  security_groups    = [module.alb_sg.security_group_id]
  subnet_ids         = module.networking.public_subnet_ids
  http_tcp_listeners = [
    {
      port           = 80
      protocol       = "HTTP"
      action_type    = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Resource not found"
        status_code  = "404"
      }
    }
  ]
}

resource "aws_ecs_cluster" "main" {
  name               = var.project
  capacity_providers = null
}

resource "aws_service_discovery_private_dns_namespace" "segment" {
  name        = "discovery.com"
  description = "Service discovery for backends"
  vpc         = module.networking.vpc_id
}

################################################################################
# BOOKS API ECS Service
################################################################################
resource "aws_alb_target_group" "books_api_tg" {
  name        = var.books_api_tg
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.books_api_health_check_path
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener_rule" "books_api_listener_rule" {
  listener_arn = module.public_alb.alb_listener_http_tcp_arn
  priority     = 1

  action {
    type             = "forward" # Redirect all traffic from the ALB to the target group
    target_group_arn = aws_alb_target_group.books_api_tg.arn
  }

  condition {
    path_pattern {
      values = var.books_api_tg_paths
    }
  }
}

module "ecs_books_api_fargate" {
  source                                  = "../modules/ecs"
  aws_region                              = var.aws_region
  aws_ecs_cluster_id                      = aws_ecs_cluster.main.id
  has_discovery                           = true
  dns_namespace_id                        = aws_service_discovery_private_dns_namespace.segment.id
  service_security_groups_ids             = [module.ecs_tasks_sg.security_group_id]
  subnet_ids                              = module.networking.private_subnet_ids
  assign_public_ip                        = false
  iam_role_ecs_task_execution_role        = aws_iam_role.ecs_task_execution_role
  iam_role_policy_ecs_task_execution_role = aws_iam_role_policy_attachment.ecs_task_execution_role
  logs_retention_in_days                  = 30
  fargate_cpu                             = var.fargate_cpu
  fargate_memory                          = var.fargate_memory
  health_check_grace_period_seconds       = var.health_check_grace_period_seconds
  service_name                            = var.books_api_name
  service_image                           = var.books_api_image
  service_aws_logs_group                  = var.books_api_aws_logs_group
  service_port                            = var.books_api_port
  service_desired_count                   = var.books_api_desired_count
  service_max_count                       = var.books_api_max_count
  service_task_family                     = var.books_api_task_family
  service_enviroment_variables            = []
  network_mode                            = var.books_api_network_mode
  task_compatibilities                    = var.books_api_task_compatibilities
  launch_type                             = var.books_api_launch_type
  alb_listener                            = module.public_alb.alb_listener
  has_alb                                 = true
  alb_target_group                        = aws_alb_target_group.books_api_tg.id
}

################################################################################
# RECOMMENDATION API ECS Service
################################################################################
module "ecs_recommendations_api_fargate" {
  source                                  = "../modules/ecs"
  aws_region                              = var.aws_region
  aws_ecs_cluster_id                      = aws_ecs_cluster.main.id
  has_discovery                           = true
  dns_namespace_id                        = aws_service_discovery_private_dns_namespace.segment.id
  service_security_groups_ids             = [module.private_ecs_tasks_sg.security_group_id]
  subnet_ids                              = module.networking.private_subnet_ids
  assign_public_ip                        = false
  iam_role_ecs_task_execution_role        = aws_iam_role.ecs_task_execution_role
  iam_role_policy_ecs_task_execution_role = aws_iam_role_policy_attachment.ecs_task_execution_role
  logs_retention_in_days                  = 30
  fargate_cpu                             = "256"
  fargate_memory                          = "512"
  health_check_grace_period_seconds       = 180
  service_name                            = "recommendations_api"
  service_image                           = "eldimious/recommendations:latest"
  service_aws_logs_group                  = "/ecs/recommendations_api"
  service_port                            = 3333
  service_desired_count                   = 2
  service_max_count                       = 4
  service_task_family                     = "recommendations_api_task"
  service_enviroment_variables            = []
  network_mode                            = "awsvpc"
  task_compatibilities                    = ["FARGATE"]
  launch_type                             = "FARGATE"
  alb_listener                            = module.public_alb.alb_listener
  has_alb                                 = false
  alb_target_group                        = null
}

################################################################################
# USERS API ECS Service
################################################################################
resource "aws_alb_target_group" "users_api_tg" {
  name        = "users-api-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/users/health-check"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener_rule" "users_api_listener_rule" {
  listener_arn = module.public_alb.alb_listener_http_tcp_arn
  priority     = 2

  action {
    type             = "forward" # Redirect all traffic from the ALB to the target group
    target_group_arn = aws_alb_target_group.users_api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/users", "/users/*"]
    }
  }
}

module "ecs_users_api_fargate" {
  source                                  = "../modules/ecs"
  aws_region                              = var.aws_region
  aws_ecs_cluster_id                      = aws_ecs_cluster.main.id
  has_discovery                           = true
  dns_namespace_id                        = aws_service_discovery_private_dns_namespace.segment.id
  service_security_groups_ids             = [module.ecs_tasks_sg.security_group_id]
  subnet_ids                              = module.networking.private_subnet_ids
  assign_public_ip                        = false
  iam_role_ecs_task_execution_role        = aws_iam_role.ecs_task_execution_role
  iam_role_policy_ecs_task_execution_role = aws_iam_role_policy_attachment.ecs_task_execution_role
  logs_retention_in_days                  = 30
  fargate_cpu                             = "256"
  fargate_memory                          = "512"
  health_check_grace_period_seconds       = 180
  service_name                            = "users_api"
  service_image                           = "eldimious/users:latest"
  service_aws_logs_group                  = "/ecs/users_api"
  service_port                            = 3000
  service_desired_count                   = 2
  service_max_count                       = 4
  service_task_family                     = "users_api_task"
  service_enviroment_variables            = [
    {
      "name": "RECOMMENDATIONS_SERVICE_URL",
      "value": "http://${module.ecs_recommendations_api_fargate.aws_service_discovery_service_name}.${aws_service_discovery_private_dns_namespace.segment.name}:${var.recommendations_api_port}"
    }
  ]
  network_mode                            = "awsvpc"
  task_compatibilities                    = ["FARGATE"]
  launch_type                             = "FARGATE"
  alb_listener                            = module.public_alb.alb_listener
  has_alb                                 = true
  alb_target_group                        = aws_alb_target_group.users_api_tg.id
}
