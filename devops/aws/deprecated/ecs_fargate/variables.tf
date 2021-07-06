################################################################################
# General AWS Configuration
################################################################################
variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-west-2"
}
//variable "docker_repo" {}

################################################################################
# Network Configuration
################################################################################
variable "cidr_block" {
  description = "Network IP range"
  default     = "172.17.0.0/16"
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
# Project metadata
################################################################################
variable "project" {
  description = "Project name"
  default     = "ecs_fargate_ms"
}

variable "environment" {
  description = "Indicate the environment"
  default     = "dec"
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
variable "books_api_name" {
  description = "Defines service name"
  default     = "books_api"
}

variable "books_api_image" {
  description = "Defines service image"
  default     = "eldimious/books:latest"
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
  default     = 5000
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

################################################################################
# API Users Service Configuration
################################################################################
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
  default     = 3333
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
