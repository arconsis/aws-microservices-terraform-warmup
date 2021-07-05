output "autoscaling_group_arn" {
  description = "The ARN of the auto scaling group."
  value       = concat(aws_autoscaling_group.this.*.arn, [""])[0]
}
