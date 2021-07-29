provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = var.aws_region
}

################################################################################
# VPC Configuration
################################################################################
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

################################################################################
# SG Configuration
################################################################################
module "private_vpc_sg" {
  source                   = "../modules/security"
  create_vpc               = var.create_vpc
  create_sg                = true
  sg_name                  = "private-lambda-security-group"
  description              = "Controls access to the private lambdas (not internet facing)"
  rule_ingress_description = "allow inbound access only from resources in VPC"
  rule_egress_description  = "allow all outbound"
  vpc_id                   = module.networking.vpc_id
  ingress_cidr_blocks      = [var.cidr_block]
  ingress_from_port        = 0
  ingress_to_port          = 0
  ingress_protocol         = "-1"
  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_from_port         = 0
  egress_to_port           = 0
  egress_protocol          = "-1"
}

################################################################################
# Lambdas Configuration
################################################################################
module "create_user_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "create-user"
  description   = "Create new user"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true

  source_path = "../../../lambdas/users/createUser"

  store_on_s3 = true
  s3_bucket   = "my-bucket-id-with-lambda-builds"

  vpc_subnet_ids         = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.private_vpc_sg.security_group_id]
  attach_network_policy = true

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }

  environment_variables = {
    Serverless = "Terraform"
  }
}

module "get_user_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "get-user"
  description   = "Get specific user"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true

  source_path = "../../../lambdas/users/getUser"

  store_on_s3 = true
  s3_bucket   = "my-bucket-id-with-lambda-builds"

  vpc_subnet_ids         = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.private_vpc_sg.security_group_id]
  attach_network_policy = true

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }

  environment_variables = {
    Serverless = "Terraform"
  }
}

module "list_users_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "list-users"
  description   = "Get list of user"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true

  source_path = "../../../lambdas/users/listUsers"

  store_on_s3 = true
  s3_bucket   = "my-bucket-id-with-lambda-builds"

  vpc_subnet_ids         = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.private_vpc_sg.security_group_id]
  attach_network_policy = true

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }

  environment_variables = {
    Serverless = "Terraform"
  }
}

################################################################################
# API GW Configuration
################################################################################
module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "dev-http"
  description   = "HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_api_domain_name = false
  # Routes and integrations
  integrations = {
    "POST /users" = {
      lambda_arn             = module.create_user_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "GET /users" = {
      lambda_arn             = module.list_users_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "GET /users/{userId}" = {
      lambda_arn             = module.get_user_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
  }

  tags = {
    Name = "http-apigateway"
  }
}
