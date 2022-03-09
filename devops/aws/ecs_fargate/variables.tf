################################################################################
# General AWS Configuration
################################################################################
variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "The AWS profile name"
  default     = "arconsis"
}

################################################################################
# Network Configuration
################################################################################
################################################################################
variable "vpc_name" {
  description = "The name of the VPC. Other names will result from this."
  default     = "ms-vpc"
}

variable "public_subnet_count" {
  type        = number
  description = "Public subnet count"
  default     = 2
}

variable "private_subnet_count" {
  type        = number
  description = "Private subnet count"
  default     = 2
}

variable "cidr_block" {
  description = "Network IP range"
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  description = "DNS support"
  default     = true
}

variable "enable_dns_hostnames" {
  description = "DNS hostnames"
  default     = true
}

################################################################################
# ALB
################################################################################
variable "create_alb" {
  description = "Flag to define if we have to create ALB"
  type        = bool
  default     = true
}

################################################################################
# Project metadata
################################################################################
variable "project" {
  description = "Project name"
  default     = "ecs_fargate_ms"
}

variable "environment" {
  description = "Indicate the environment"
  default     = "dev"
}

################################################################################
# ECS Configuration
################################################################################
variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "ecsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "health_check_grace_period_seconds" {
  description = ""
  default     = 180
}

variable "network_mode" {
  description = "Set network mode of esc tasks"
  default     = "awsvpc"
}

################################################################################
# API Books Service Configuration
################################################################################
variable "books_api_tg" {
  description = "Defines service tg"
  default     = "books-api-tg"
}

variable "books_api_tg_paths" {
  default = ["/books", "/books/*"]
}

variable "books_api_name" {
  description = "Defines service name"
  default     = "books_api"
}

variable "books_api_image" {
  description = "Defines service image"
  default     = "143441946271.dkr.ecr.eu-west-1.amazonaws.com/books:latest"
}

variable "books_api_aws_logs_group" {
  description = "Defines logs group"
  default     = "/ecs/books_api"
}

variable "books_api_task_family" {
  description = "Defines logs group"
  default     = "books_api_task"
}

variable "books_api_port" {
  description = "Port exposed by the books image"
  default     = 3000
}

variable "books_api_desired_count" {
  description = "Number of books docker containers to run"
  default     = 2
}

variable "books_api_max_count" {
  description = "Max number of books docker containers to run"
  default     = 4
}

variable "books_api_health_check_path" {
  default = "/books/health-check"
}

variable "books_api_network_mode" {
  default = "awsvpc"
}

variable "books_api_task_compatibilities" {
  default = ["FARGATE"]
}

variable "books_api_launch_type" {
  default = "FARGATE"
}

################################################################################
# API Users Service Configuration
################################################################################
variable "users_api_tg" {
  description = "Defines service tg"
  default     = "users-api-tg"
}

variable "users_api_tg_paths" {
  default = ["/users", "/users/*"]
}

variable "users_api_name" {
  description = "Defines service name"
  default     = "users_api"
}

variable "users_api_image" {
  description = "Defines service image"
  default     = "eldimious/users:latest"
}

variable "users_api_aws_logs_group" {
  description = "Defines logs group"
  default     = "/ecs/users_api"
}

variable "users_api_task_family" {
  description = "Defines logs group"
  default     = "users_api_task"
}

variable "users_api_port" {
  description = "Port exposed by the users image"
  default     = 3000
}

variable "users_api_desired_count" {
  description = "Number of users docker containers to run"
  default     = 2
}

variable "users_api_max_count" {
  description = "Max number of users docker containers to run"
  default     = 4
}

variable "users_api_health_check_path" {
  default = "/users/health-check"
}

variable "users_api_network_mode" {
  default = "awsvpc"
}

variable "users_api_task_compatibilities" {
  default = ["FARGATE"]
}

variable "users_api_launch_type" {
  default = "FARGATE"
}

################################################################################
# API Promotions Service Configuration
################################################################################
variable "promotions_api_tg" {
  description = "Defines service tg"
  default     = "promotions-api-tg"
}

variable "promotions_api_tg_paths" {
  default = ["/promotions", "/promotions/*"]
}

variable "promotions_api_name" {
  description = "Defines service name"
  default     = "promotions_api"
}

variable "promotions_api_image" {
  description = "Defines service image"
  default     = "eldimious/promotions:latest"
}

variable "promotions_api_aws_logs_group" {
  description = "Defines logs group"
  default     = "/ecs/promotions_api"
}

variable "promotions_api_task_family" {
  description = "Defines logs group"
  default     = "promotions_api_task"
}

variable "promotions_api_port" {
  description = "Port exposed by the users image"
  default     = 8080
}

variable "promotions_api_desired_count" {
  description = "Number of users docker containers to run"
  default     = 2
}

variable "promotions_api_max_count" {
  description = "Max number of users docker containers to run"
  default     = 4
}

variable "promotions_api_health_check_path" {
  default = "/promotions/"
}

variable "promotions_api_network_mode" {
  default = "awsvpc"
}

variable "promotions_api_task_compatibilities" {
  default = ["FARGATE"]
}

variable "promotions_api_launch_type" {
  default = "FARGATE"
}

################################################################################
# API Recommendations Service Configuration
################################################################################
variable "recommendations_api_name" {
  description = "Defines service name"
  default     = "recommendations_api"
}

variable "recommendations_api_image" {
  description = "Defines service image"
  default     = "eldimious/recommendations:latest"
}

variable "recommendations_api_aws_logs_group" {
  description = "Defines logs group"
  default     = "/ecs/recommendations_api"
}

variable "recommendations_api_task_family" {
  description = "Defines logs group"
  default     = "recommendations_api_task"
}

variable "recommendations_api_port" {
  description = "Port exposed by the recommendations image"
  default     = 3000
}

variable "recommendations_api_desired_count" {
  description = "Number of recommendations docker containers to run"
  default     = 2
}

variable "recommendations_api_max_count" {
  description = "Max number of recommendations docker containers to run"
  default     = 4
}

variable "recommendations_api_health_check_path" {
  default = "/recommendations/health-check"
}

variable "recommendations_api_network_mode" {
  default = "awsvpc"
}

variable "recommendations_api_task_compatibilities" {
  default = ["FARGATE"]
}

variable "recommendations_api_launch_type" {
  default = "FARGATE"
}

################################################################################
# ALB Configuration
################################################################################
variable "internal_elb" {
  description = "Make ALB private? (Compute nodes are always private under ALB)"
  default     = false
}

################################################################################
# Discovery Service Configuration
################################################################################
variable "discovery_ttl" {
  description = "Time to live"
  default     = 10
}

variable "discovery_routing_policy" {
  description = "Defines routing policy"
  default     = "MULTIVALUE"
}

################################################################################
# Database Configuration
################################################################################
# Books DB
variable "books_database_username" {
  description = "The username for the books DB master"
  type        = string
  sensitive   = true
}

variable "books_database_password" {
  description = "The password for the books DB master"
  type        = string
  sensitive   = true
}

# Recommendations DB
variable "recommendations_database_username" {
  description = "The username for the recommendations DB master"
  type        = string
  sensitive   = true
}

variable "recommendations_database_password" {
  description = "The password for the recommendations DB master"
  type        = string
  sensitive   = true
}

# Users DB
variable "users_database_username" {
  description = "The username for the users DB master"
  type        = string
  sensitive   = true
}

variable "users_database_password" {
  description = "The password for the users DB master"
  type        = string
  sensitive   = true
}

variable "default_tags" {
  description = "Default tags to set to every resource"
  type        = map(string)
  default     = {
    Project     = "ecs-fargate-aws-warmup"
    ManagedBy   = "terraform"
  }
}
