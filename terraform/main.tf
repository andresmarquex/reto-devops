terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ==================================================================
# 🌐 REDES: Amazon VPC & Subnets (Punto 2)
# ==================================================================
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "lite-thinking-vpc" }
}

# Subnets Públicas (Para el ALB y NAT Gateways)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                 = { Name = "public-subnet-${count.index}" }
}

# Subnets Privadas (Para Aplicaciones / EC2 / Nodos EKS)
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = { Name = "private-app-subnet-${count.index}" }
}

# Subnets Privadas de Datos (Para el clúster RDS Multi-AZ)
resource "aws_subnet" "private_data" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 20}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = { Name = "private-data-subnet-${count.index}" }
}

# Puerta de enlace a Internet (Internet Gateway)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# Tabla de Ruteo Pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ==================================================================
# 🛡️ SEGURIDAD: Security Groups (Firewalls Stateful - Punto 4)
# ==================================================================

# Security Group del Balanceador (ALB)
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Permite trafico HTTPS entrante desde el mundo"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
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

# Security Group de la Instancia EC2 (Capa de Aplicación)
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Permite trafico unicamente proveniente del ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # 💡 Principio de minimo privilegio
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group de la Base de Datos RDS
resource "aws_security_group" "db_sg" {
  name        = "rds-security-group"
  description = "Permite acceso exclusivo en el puerto de PostgreSQL desde la capa App"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # Solo la app habla con la BD
  }
}

# ==================================================================
# 💻 CÓMPUTO Y ALTA DISPONIBILIDAD: EC2 & ALB (Punto 1)
# ==================================================================
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private_app[0].id # Alojado en subnet privada segura
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true # Hardening de datos en reposo
  }

  tags = { Name = "critical-web-server" }
}

resource "aws_lb" "external_alb" {
  name               = "production-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
}

# ==================================================================
# 🗄️ PERSISTENCIA: Amazon RDS Multi-AZ (Punto 5)
# ==================================================================
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-main-subnet-group"
  subnet_ids = aws_subnet.private_data[*].id
}

resource "aws_db_instance" "postgres" {
  identifier             = "lite-thinking-production-db"
  allocated_storage      = 20
  max_allocated_storage  = 100 # Escalabilidad automatizada de almacenamiento
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.medium"
  db_name                = "production_db"
  username               = "cloud_admin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids =