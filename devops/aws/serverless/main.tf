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
# S3 Buckets Configuration
################################################################################
module "users_profile_images_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "users-profile-images-tf"
  acl    = "private"
  force_destroy = true
}

module "users_thumbnails_images_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "users-thumbnails-images-tf"
  acl    = "private"
  force_destroy = true
}

################################################################################
# SQS Queue Configuration
################################################################################
resource "aws_sqs_queue" "users_profile_images_queue" {
  name = "users-profile-images"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:users-profile-images",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${module.users_profile_images_bucket.s3_bucket_arn}" }
      }
    }
  ]
}
POLICY
}

################################################################################
# S3 - SQS Notifications
################################################################################
resource "aws_s3_bucket_notification" "users_profile_images_notification" {
  bucket = module.users_profile_images_bucket.s3_bucket_id

  queue {
    queue_arn     = aws_sqs_queue.users_profile_images_queue.arn
    events        = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sqs_queue.users_profile_images_queue]
}

################################################################################
# Database Configuration
################################################################################

# module "aurora_postgresql" {
#   source  = "terraform-aws-modules/rds-aurora/aws"
#   version = "~> 3.0"

#   name           = "aurora-db-postgres"
#   engine         = "aurora-postgresql"
#   engine_version = "11.9"
#   instance_type  = "db.t3.medium"

#   vpc_id  = module.networking.vpc_id
#   subnets = module.networking.private_subnet_ids

#   replica_count           = 1
#   allowed_security_groups = [module.private_vpc_sg.security_group_id]
#   # allowed_cidr_blocks     = ["10.20.0.0/20"]

#   storage_encrypted   = true
#   apply_immediately   = true
#   monitoring_interval = 10

#   # db_parameter_group_name         = "main"
#   # db_cluster_parameter_group_name = "main"

#   enabled_cloudwatch_logs_exports = ["postgresql"]

#   tags = {
#     Environment = "dev"
#   }
# }

module "users_database" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "users-database"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "11.10"
  family               = "postgres11" # DB parameter group
  major_engine_version = "11"         # DB option group
  instance_class       = "db.t3.small"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  name     = "postgres"
  username = var.users_database_username
  password = var.users_database_password
  port     = 5432

  multi_az               = true
  subnet_ids             = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.private_vpc_sg.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
}

module "posts_database" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "posts-database"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "11.10"
  family               = "postgres11" # DB parameter group
  major_engine_version = "11"         # DB option group
  instance_class       = "db.t3.small"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  name     = "postgres"
  username = var.posts_database_username
  password = var.posts_database_password
  port     = 5432

  multi_az               = true
  subnet_ids             = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.private_vpc_sg.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_role_name                  = "PostsDatabaseMonitoringRole"
  monitoring_interval                   = 60

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
}

################################################################################
# Lambdas Layer Configuration
################################################################################
module "lambda_layer_logging" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = true

  layer_name          = "lambda-layer-logging"
  description         = "Help on lambda logging"
  compatible_runtimes = ["nodejs14.x"]

  source_path = "../../../backend/serverless/layers/logging"

  store_on_s3 = true
  s3_bucket   = "my-bucket-id-with-lambda-builds"
}

module "lambda_layer_users_database" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = true

  layer_name          = "lambda-layer-users-database"
  description         = "Handle lambdas database integration"
  compatible_runtimes = ["nodejs14.x"]

  source_path = "../../../backend/serverless/layers/usersDatabase"

  store_on_s3 = true
  s3_bucket   = "my-bucket-id-with-lambda-builds"
}

module "lambda_layer_posts_database" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = true

  layer_name          = "lambda-layer-post-database"
  description         = "Handle lambdas post database integration"
  compatible_runtimes = ["nodejs14.x"]

  source_path = "../../../backend/serverless/layers/postsDatabase"

  store_on_s3 = true
  s3_bucket   = "my-bucket-id-with-lambda-builds"
}

################################################################################
# Lambdas Configuration
################################################################################
################################################################################
# AUTH
################################################################################
module "jwt_auth" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "jwt_auth"
  description   = "Verifies JWT"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true

  source_path = "../../../backend/serverless/lambdas/auth/verifyToken"

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

  attach_dead_letter_policy = false
  
  layers = [
    module.lambda_layer_logging.lambda_layer_arn
  ]

  environment_variables = {
    JWT_SECRET = var.jwt_secret
  }
}

module "basic_auth" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "basic_auth"
  description   = "Verifies basic authentication"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true

  source_path = "../../../backend/serverless/lambdas/auth/verifyBasicAuth"

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

  attach_dead_letter_policy = false
  
  layers = [
    module.lambda_layer_logging.lambda_layer_arn
  ]

  environment_variables = {
    BASIC_AUTH_USERNAME = var.basic_auth_username
    BASIC_AUTH_PASSWORD = var.basic_auth_password
  }
}

module "login" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "login"
  description   = "Handles token generation"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../../backend/serverless/lambdas/auth/login"

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

  attach_dead_letter_policy = false
  
  layers = [
    module.lambda_layer_logging.lambda_layer_arn,
    module.lambda_layer_users_database.lambda_layer_arn
  ]

  environment_variables = {
    DB_HOST = module.users_database.db_instance_address,
    DB_PORT = module.users_database.db_instance_port,
    DB_NAME = module.users_database.db_instance_name,
    DB_USER = module.users_database.db_instance_username,
    DB_PASS = module.users_database.db_master_password,
    JWT_SECRET = var.jwt_secret
  }
}
################################################################################
# ADMINS Lambdas
################################################################################
module "create_admin_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "create-admin"
  description   = "Create new admin"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../../backend/serverless/lambdas/admins/createAdmin"

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

  attach_dead_letter_policy = false

  layers = [
    module.lambda_layer_logging.lambda_layer_arn,
    module.lambda_layer_users_database.lambda_layer_arn
  ]

  depends_on = [module.users_database]

  environment_variables = {
    DB_HOST = module.users_database.db_instance_address,
    DB_PORT = module.users_database.db_instance_port,
    DB_NAME = module.users_database.db_instance_name,
    DB_USER = module.users_database.db_instance_username,
    DB_PASS = module.users_database.db_master_password,
  }
}

################################################################################
# USERS Lambdas
################################################################################
module "create_user_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "create-user"
  description   = "Create new user"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../../backend/serverless/lambdas/users/createUser"

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

  attach_dead_letter_policy = false

  layers = [
    module.lambda_layer_logging.lambda_layer_arn,
    module.lambda_layer_users_database.lambda_layer_arn
  ]

  depends_on = [module.users_database]

  environment_variables = {
    DB_HOST = module.users_database.db_instance_address,
    DB_PORT = module.users_database.db_instance_port,
    DB_NAME = module.users_database.db_instance_name,
    DB_USER = module.users_database.db_instance_username,
    DB_PASS = module.users_database.db_master_password,
  }
}

module "get_user_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "get-user"
  description   = "Get specific user"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../../backend/serverless/lambdas/users/getUser"

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

  attach_dead_letter_policy = false

  layers = [
    module.lambda_layer_logging.lambda_layer_arn,
    module.lambda_layer_users_database.lambda_layer_arn
  ]

  environment_variables = {
    DB_HOST = module.users_database.db_instance_address,
    DB_PORT = module.users_database.db_instance_port,
    DB_NAME = module.users_database.db_instance_name,
    DB_USER = module.users_database.db_instance_username,
    DB_PASS = module.users_database.db_master_password,
  }
}

module "list_users_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "list-users"
  description   = "List users"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../../backend/serverless/lambdas/users/listUsers"

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

  attach_dead_letter_policy = false

  layers = [
    module.lambda_layer_logging.lambda_layer_arn,
    module.lambda_layer_users_database.lambda_layer_arn
  ]

  environment_variables = {
    DB_HOST = module.users_database.db_instance_address,
    DB_PORT = module.users_database.db_instance_port,
    DB_NAME = module.users_database.db_instance_name,
    DB_USER = module.users_database.db_instance_username,
    DB_PASS = module.users_database.db_master_password,
  }
}

module "update_user_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "update-user"
  description   = "Update specific user"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../../backend/serverless/lambdas/users/updateUser"

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

  attach_dead_letter_policy = false
  attach_policies           = true
  number_of_policies        = 1
  policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]

  layers = [
    module.lambda_layer_logging.lambda_layer_arn,
    module.lambda_layer_users_database.lambda_layer_arn
  ]

  environment_variables = {
    DB_HOST = module.users_database.db_instance_address,
    DB_PORT = module.users_database.db_instance_port,
    DB_NAME = module.users_database.db_instance_name,
    DB_USER = module.users_database.db_instance_username,
    DB_PASS = module.users_database.db_master_password,
    AWS_S3_REGION = var.aws_region
    AWS_S3_BUCKET = module.users_profile_images_bucket.s3_bucket_id
  }
}

module "modify_user_profile_image_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "modify-user-profile-image"
  description   = "Modify specific user profile image"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  # Queue visibility timeout: 30 seconds is less than Function timeout: 60 seconds
  timeout       = 30

  source_path = "../../../backend/serverless/lambdas/users/updateThumbnails"

  store_on_s3 = true
  s3_bucket   = "my-bucket-id-with-lambda-builds"

  vpc_subnet_ids         = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.private_vpc_sg.security_group_id]
  attach_network_policy = true

  attach_dead_letter_policy = false
  attach_policies           = true
  number_of_policies        = 2
  policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
  ]

  event_source_mapping = {
    sqs = {
      event_source_arn = aws_sqs_queue.users_profile_images_queue.arn
    }
  }

  allowed_triggers = {
    sqs = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.users_profile_images_queue.arn
    }
  }

  layers = [
    module.lambda_layer_logging.lambda_layer_arn,
    module.lambda_layer_users_database.lambda_layer_arn
  ]

  environment_variables = {
    DB_HOST = module.users_database.db_instance_address,
    DB_PORT = module.users_database.db_instance_port,
    DB_NAME = module.users_database.db_instance_name,
    DB_USER = module.users_database.db_instance_username,
    DB_PASS = module.users_database.db_master_password,
    AWS_S3_REGION = var.aws_region
    AWS_S3_BUCKET = module.users_thumbnails_images_bucket.s3_bucket_id
    AWS_SQS_REGION = var.aws_region
    AWS_SQS_QUEUE_URL = aws_sqs_queue.users_profile_images_queue.url
  }
}

################################################################################
# POSTS Lambdas
################################################################################
module "create_post_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "create-post"
  description   = "Create new post for user"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../../backend/serverless/lambdas/posts/createPost"

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

  attach_dead_letter_policy = false

  layers = [
    module.lambda_layer_logging.lambda_layer_arn,
    module.lambda_layer_posts_database.lambda_layer_arn
  ]

  depends_on = [module.posts_database]

  environment_variables = {
    DB_HOST = module.posts_database.db_instance_address,
    DB_PORT = module.posts_database.db_instance_port,
    DB_NAME = module.posts_database.db_instance_name,
    DB_USER = module.posts_database.db_instance_username,
    DB_PASS = module.posts_database.db_master_password,
  }
}

module "list_user_posts_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "list-users-post"
  description   = "List user posts"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true
  timeout       = 60

  source_path = "../../../backend/serverless/lambdas/posts/listPosts"

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

  attach_dead_letter_policy = false

  layers = [
    module.lambda_layer_logging.lambda_layer_arn,
    module.lambda_layer_posts_database.lambda_layer_arn
  ]

  depends_on = [module.posts_database]

  environment_variables = {
    DB_HOST = module.posts_database.db_instance_address,
    DB_PORT = module.posts_database.db_instance_port,
    DB_NAME = module.posts_database.db_instance_name,
    DB_USER = module.posts_database.db_instance_username,
    DB_PASS = module.posts_database.db_master_password,
  }
}

################################################################################
# API GW Configuration
################################################################################
module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "main-GW-${var.environment}"
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
    # Auth
    "POST /login" = {
      lambda_arn             = module.login.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
    # Admins
    "POST /admins" = {
      lambda_arn             = module.create_admin_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      authorization_type     = "CUSTOM"
      authorizer_id          = aws_apigatewayv2_authorizer.basic_auth.id
    }
    # Users
    "POST /users" = {
      lambda_arn             = module.create_user_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      authorization_type     = "CUSTOM"
      authorizer_id          = aws_apigatewayv2_authorizer.jwt_auth.id
    }
    "GET /users" = {
      lambda_arn             = module.list_users_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      authorization_type     = "CUSTOM"
      authorizer_id          = aws_apigatewayv2_authorizer.jwt_auth.id
    }
    "GET /users/{userId}" = {
      lambda_arn             = module.get_user_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      authorization_type     = "CUSTOM"
      authorizer_id          = aws_apigatewayv2_authorizer.jwt_auth.id
    }
    "PUT /users/{userId}" = {
      lambda_arn             = module.update_user_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      authorization_type     = "CUSTOM"
      authorizer_id          = aws_apigatewayv2_authorizer.jwt_auth.id
    }
    # Posts
    "POST /users/{userId}/posts" = {
      lambda_arn             = module.create_post_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      authorization_type     = "CUSTOM"
      authorizer_id          = aws_apigatewayv2_authorizer.jwt_auth.id
    }
    "GET /users/{userId}/posts" = {
      lambda_arn             = module.list_user_posts_lambda.lambda_function_invoke_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      authorization_type     = "CUSTOM"
      authorizer_id          = aws_apigatewayv2_authorizer.jwt_auth.id
    }
  }

  tags = {
    Name = "http-apigateway"
  }
}

resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = file("../common/templates/policies/api_gateway_auth_invocation.json.tpl")
}

################################################################################
# API GW Authorizer Configuration
################################################################################
resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${module.jwt_auth.lambda_function_arn}"
    }
  ]
}
EOF
}

resource "aws_apigatewayv2_authorizer" "jwt_auth" {
  api_id           = module.api_gateway.apigatewayv2_api_id
  authorizer_type  = "REQUEST"
  identity_sources = ["$request.header.Authorization"]
  name             = "LambdaAuthorizer"
  authorizer_uri   = module.jwt_auth.lambda_function_invoke_arn
  authorizer_payload_format_version = "2.0"
  enable_simple_responses = true
  authorizer_credentials_arn = aws_iam_role.invocation_role.arn
}

resource "aws_iam_role_policy" "basic_auth_invocation_policy" {
  name = "basic_auth_invocation_policy"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${module.basic_auth.lambda_function_arn}"
    }
  ]
}
EOF
}

resource "aws_apigatewayv2_authorizer" "basic_auth" {
  api_id           = module.api_gateway.apigatewayv2_api_id
  authorizer_type  = "REQUEST"
  identity_sources = ["$request.header.Authorization"]
  name             = "LambdaBasicAuthorizer"
  authorizer_uri   = module.basic_auth.lambda_function_invoke_arn
  authorizer_payload_format_version = "2.0"
  enable_simple_responses = true
  authorizer_credentials_arn = aws_iam_role.invocation_role.arn
}
