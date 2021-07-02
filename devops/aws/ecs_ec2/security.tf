################################################################################
# ALB SG
################################################################################
resource "aws_security_group" "lb" {
  name        = "load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id = aws_vpc.main.id

  # Accept incoming access to port 80 from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################################################
# ECS cluster tasks SG
################################################################################
resource "aws_security_group" "ec2_sg" {
  name        = "ecs-tasks-ec2-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.main.id

  # Traffic to the ECS cluster should only come from the ALB SG
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

################################################################################
# PRIVATE ECS cluster tasks SG
################################################################################
resource "aws_security_group" "private_ecs_ec2_tasks" {
  name        = "private-ecs-tasks-security-group"
  description = "private ecs tasks, not internet facing. allow inbound access from other ecs tasks only"
  vpc_id      = aws_vpc.main.id

  # Traffic to the ECS cluster should only come from the other ecs tasks in vpc
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
