# region
variable "region" {
  description = "The region to use for this module."
  default     = "us-west-2"
}

################################################################################
# Project metadata
################################################################################

variable "default_tags" {
  description = "Default tags to set to every resource"
  type        = map(string)
}

variable "vpc_name" {
  description = "The name of the VPC. Other names will result from this."
  default     = "ms-vpc"
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
}

variable "public_subnets" {
  type = list(string)

  description = "Public subnet AZs"
}

variable "private_subnets" {
  type = list(string)

  description = "Private subnet AZs"
}
