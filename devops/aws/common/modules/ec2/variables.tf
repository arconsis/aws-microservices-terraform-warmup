variable "launch_configuration_name" {
  description = "Name of launch configuration"
  type        = string
}

variable "iam_ecs_service_role_name" {
  description = "Name of iam role"
  type        = string
}

variable "security_groups_ids" {
  description = "IDs of security groups for ec2"
  type        = list(any)
}

variable "assign_public_ip" {
  description = "Flag to determine if we have to assign public ip"
  type        = bool
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "aws_autoscaling_group_name" {
  description = "Auto scaling group name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnets"
  type        = list(any)
}
