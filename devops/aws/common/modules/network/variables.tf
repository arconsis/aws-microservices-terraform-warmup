# region
variable "region" {
  description = "The region to use for this module."
  default     = "us-west-2"
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

# vpc
variable "create_vpc" {
  description = "Define if we have to create new VPC"
  default     = true
}

variable "vpc_name" {
  description = "The name of the VPC. Other names will result from this."
  default     = "ms-vpc"
}

variable "create_igw" {
  description = "Define if we have to create IG"
  default     = true
}

# network resources
variable "enable_dns_support" {
  default     = true
  description = " (Optional) A boolean flag to enable/disable DNS support in the VPC"
}

variable "enable_dns_hostnames" {
  default     = true
  description = " (Optional) A boolean flag to enable/disable DNS hostnames in the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "Cidr block for vpc"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(string)

  description = "Public subnet AZs"
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "private_subnets" {
  type = list(string)

  description = "Private subnet AZs"
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnet_additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "private_subnet_additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
