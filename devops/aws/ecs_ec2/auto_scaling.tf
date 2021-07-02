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

resource "aws_launch_configuration" "lc" {
  name          = "ec2_ecs_launch_configuration"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ecs_service_role.name
  security_groups             = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false
  user_data                   = <<EOF
#! /bin/bash
sudo apt-get update
sudo echo "ECS_CLUSTER=${var.project}" >> /etc/ecs/ecs.config
EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ec2_ecs_asg" {
  name                      = "ec2-ecs-asg"
  launch_configuration      = aws_launch_configuration.lc.name
  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 5
  force_delete              = true
  load_balancers            = [] # Only used when NOT using ALB
  # health_check_type         = "ELB"
  # health_check_type         = "EC2"
  health_check_grace_period = 300
  vpc_zone_identifier       = aws_subnet.private.*.id
  # target_group_arns         = [aws_alb_target_group.books_api_tg.arn]
  protect_from_scale_in     = true
  lifecycle {
    create_before_destroy = true
  }
}
