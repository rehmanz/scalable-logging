output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.slogging_db.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.slogging_db.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.slogging_db.username
  sensitive   = true
}

output "rds_password" {
  description = "RDS instance root password"
  value       = aws_db_instance.slogging_db.password
  sensitive   = true
}
