variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Región de AWS para el despliegue"
}

variable "ami_id" {
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu Server 22.04 LTS en us-east-1
  description = "AMI base para las instancias EC2"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Contraseña maestra para la base de datos RDS"
}