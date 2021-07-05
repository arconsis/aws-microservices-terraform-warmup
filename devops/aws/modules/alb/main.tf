################################################################################
# ALB Definition
################################################################################
resource "aws_alb" "this" {
  count = var.create_alb ? 1 : 0

  name               = var.alb_name
  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  security_groups    = var.security_groups
  subnets            = var.subnet_ids
}

################################################################################
# ALB HTTP Listener Definition
################################################################################
resource "aws_alb_listener" "http_tcp" {
  count = var.create_alb ? length(var.http_tcp_listeners) : 0

  load_balancer_arn = aws_alb.this[0].arn
  port              = var.http_tcp_listeners[count.index]["port"]
  protocol          = var.http_tcp_listeners[count.index]["protocol"]

  dynamic "default_action" {
    for_each = length(keys(var.http_tcp_listeners[count.index])) == 0 ? [] : [var.http_tcp_listeners[count.index]]

    # Defaults to forward action if action_type not specified
    content {
      type = lookup(default_action.value, "action_type", "fixed-response")

      dynamic "fixed_response" {
        for_each = length(keys(lookup(default_action.value, "fixed_response", {}))) == 0 ? [] : [lookup(default_action.value, "fixed_response", {})]

        content {
          content_type = fixed_response.value["content_type"]
          message_body = lookup(fixed_response.value, "message_body", null)
          status_code  = lookup(fixed_response.value, "status_code", null)
        }
      }
    }
  }
}

# resource "aws_alb_target_group" "main" {
#   count = var.create_alb ? length(var.target_groups) : 0

#   name            = lookup(var.target_groups[count.index], "name", null)

#   vpc_id           = var.vpc_id
#   port             = lookup(var.target_groups[count.index], "backend_port", null)
#   protocol         = lookup(var.target_groups[count.index], "backend_protocol", null) != null ? upper(lookup(var.target_groups[count.index], "backend_protocol")) : null
#   target_type      = lookup(var.target_groups[count.index], "target_type", null)


#   dynamic "health_check" {
#     for_each = length(keys(lookup(var.target_groups[count.index], "health_check", {}))) == 0 ? [] : [lookup(var.target_groups[count.index], "health_check", {})]
#     content {
#       interval            = lookup(health_check.value, "interval", null)
#       path                = lookup(health_check.value, "path", null)
#       healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
#       unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
#       timeout             = lookup(health_check.value, "timeout", null)
#       protocol            = lookup(health_check.value, "protocol", null)
#       matcher             = lookup(health_check.value, "matcher", null)
#     }
#   }

#   depends_on = [aws_alb.this]

#   lifecycle {
#     create_before_destroy = true
#   }
# }
