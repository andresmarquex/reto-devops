output "alb_dns_name" {
  value       = aws_lb.external_alb.dns_name
  description = "URL pública del balanceador de carga para acceder a la aplicación"
}

output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "Endpoint de conexión interna para la base de datos"
}