resource "aws_security_group" "tcp_sg" {
  name        = "ec2-cursor-sg"
  description = "Security Group para el servidor TCP en EC2"
  vpc_id      = var.vpc_id

  # Permitir tráfico entrante en el puerto 8090 (para el servidor TCP)
  ingress {
    from_port   = 8100
    to_port     = 8100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir salida de tráfico para que EC2 pueda hacer pull de ECR
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir acceso a SSM (puerto 443 para comunicación con AWS)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfico en el puerto 22 (SSH)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ⚠️ Cambia esto por TU IP para seguridad
  }
}
