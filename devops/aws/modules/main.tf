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

# module "alb" {
# 	source             = "./alb"
#   alb_name           = "main-ecs-lb"
#   vpc_id             = module.networking.id
#   subnet_ids         = module.networking.public_subnet_ids
#   internal           = true
# }