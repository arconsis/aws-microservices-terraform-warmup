provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = var.aws_region
}

module "networking" {
	source               = "./network"
  create_vpc           = true
  single_nat_gateway   = false
  create_igw           = true
  enable_nat_gateway   = true
  region               = var.aws_region
  vpc_name             = var.vpc_name
  cidr_block           = var.cidr_block
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "alb-sg" {
  source                    = "./security"
  create_vpc                = true
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

module "ecs-tasks-sg" {
  source                            = "./security"
  create_vpc                        = true
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
  ingress_source_security_group_id  = module.alb-sg.security_group_id
  egress_cidr_blocks                = ["0.0.0.0/0"]
  egress_from_port                  = 0
  egress_to_port                    = 0
  egress_protocol                   = "-1"
}

module "private-ecs-tasks-sg" {
  source                            = "./security"
  create_vpc                        = true
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

module "alb" {
	source             = "./alb"
  create_alb         = true
  load_balancer_type = "application"
  alb_name           = "main-ecs-lb"
  internal           = false
  vpc_id             = module.networking.vpc_id
  security_groups    = [module.alb-sg.security_group_id]
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

# before create ecs we have to create with resource the "aws_alb_listener_rule" + "aws_alb_target_group" "books_api_listener_rule"
# and attach it to each ecs
