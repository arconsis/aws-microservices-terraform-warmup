output "alb_id" {
  value = aws_alb.main.id
}

output "aws_alb_main_target_group_id" {
  value = aws_alb_target_group.main.id
}

output "aws_alb_http_listener" {
  value = aws_alb_listener.http
}
