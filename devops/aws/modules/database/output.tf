output "db_address" {
  description = "The address of the RDS instance"
  value       = module.database.db_instance_address
}

output "db_arn" {
  description = "The ARN of the RDS instance"
  value       = module.database.db_instance_arn
}


output "db_endpoint" {
  description = "The connection endpoint"
  value       = module.database.db_instance_endpoint
}