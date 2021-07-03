################################################################################
# ALB Definition
################################################################################
resource "aws_alb" "main" {
  name            = var.alb_name
  subnets         = var.subnet_ids
  security_groups = var.security_groups
  internal        = var.internal
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Resource not found"
      status_code  = "404"
    }
  }
}
