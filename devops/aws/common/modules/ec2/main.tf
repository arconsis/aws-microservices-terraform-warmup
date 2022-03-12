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

resource "aws_launch_template" "this" {
  name_prefix   = var.lauch_template_name
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  iam_instance_profile {
    name = var.iam_ecs_service_role_name
  }
  vpc_security_group_ids = var.security_groups_ids
  user_data              = filebase64(
    <<EOF
#! /bin/bash
sudo apt-get update
sudo echo "ECS_CLUSTER=${var.project}" >> /etc/ecs/ecs.config
EOF
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name = var.aws_autoscaling_group_name
  launch_template {
    id      = aws_launch_template.this
    version = "$Latest"
  }
  desired_capacity          = 4
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
