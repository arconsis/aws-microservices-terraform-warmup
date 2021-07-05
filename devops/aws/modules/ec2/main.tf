data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon", "self"]
}

resource "aws_launch_configuration" "this" {
  name                        = var.launch_configuration_name
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  iam_instance_profile        = var.iam_ecs_service_role_name
  security_groups             = var.security_groups_ids
  associate_public_ip_address = var.assign_public_ip
  user_data                   = <<EOF
#! /bin/bash
sudo apt-get update
sudo echo "ECS_CLUSTER=${var.project}" >> /etc/ecs/ecs.config
EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = var.aws_autoscaling_group_name
  launch_configuration      = aws_launch_configuration.this.name
  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 5
  force_delete              = true
  load_balancers            = []
  health_check_grace_period = 300
  vpc_zone_identifier       = var.subnet_ids
  protect_from_scale_in     = true
  lifecycle {
    create_before_destroy = true
  }
}
