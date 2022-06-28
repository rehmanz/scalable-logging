output "db_hostname" {
  description = "Database instance hostname"
  value       = aws_db_instance.slogging_db.address
}

output "db_port" {
  description = "DB instance port"
  value       = aws_db_instance.slogging_db.port
}

output "db_username" {
  description = "Database instance root username"
  value       = aws_db_instance.slogging_db.username
  sensitive   = true
}

output "db_password" {
  description = "Database instance root password"
  value       = aws_db_instance.slogging_db.password
  sensitive   = true
}
