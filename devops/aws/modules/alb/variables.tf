variable "alb_name" {
  description = "The name of the loadbalancer"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "subnet_ids" {
  type        = list
  description = "List of subnets"
}

variable "internal" {
  description = "Define if alb is internal"
}

variable "deregistration_delay" {
  default     = "300"
  description = "The default deregistration delay"
}

variable "health_check_path" {
  default     = "/"
  description = "The default health check path"
}

variable "environment" {
  description = "Indicate the environment"
  default     = "dev"
}
