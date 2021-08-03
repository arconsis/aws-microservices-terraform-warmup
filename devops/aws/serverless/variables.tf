################################################################################
# General AWS Configuration
################################################################################
variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-west-1"
}

################################################################################
# Network Configuration
################################################################################
variable "vpc_name" {
  description = "The name of the VPC. Other names will result from this."
  default     = "ms-vpc"
}

variable "create_vpc" {
  description = "Flag to define if we have to create vpc"
  type        = bool
  default     = true
}

variable "create_igw" {
  description = "Flag to define if we have to create IG"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Flag to define if we need only one NAT GW"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Flag to define enable NAT GW"
  type        = bool
  default     = true
}

variable "cidr_block" {
  description = "Network IP range"
  default     = "192.168.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones you want. Example: eu-west-2a and eu-west-2b"
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnet_cidrs" {
  description = "List of public cidrs, for every availability zone you want you need one. Example: 10.0.0.0/24 and 10.0.1.0/24"
  default     = ["192.168.0.0/19", "192.168.32.0/19"]
}

variable "private_subnet_cidrs" {
  description = "List of private cidrs, for every availability zone you want you need one. Example: 10.0.0.0/24 and 10.0.1.0/24"
  default     = ["192.168.128.0/19", "192.168.160.0/19"]
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
# Database Configuration
################################################################################
# https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1
# using environment variables
variable "database_username" {
  description = "The username for the DB master user"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "The password for the DB master user"
  type        = string
  sensitive   = true
}

################################################################################
# General Configuration
################################################################################
variable "jwt_secret" {
  description = "The jwt secret we use to generate json web token"
  type        = string
  sensitive   = true
}
