variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repository_name" {
  description = "Nombre del repositorio ECR"
  type        = string
  default     = "ec2-cursor"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3a.nano"  # Instancia pequeña con 1 vCPU y 1GB RAM (Free Tier elegible)
}


variable "ami_id" {
  description = "AMI de la instancia EC2"
  type        = string
  default     = "ami-08c40ec9ead489470"  # Ubuntu 22.04 en us-east-1
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegará EC2"
  type        = string
}
