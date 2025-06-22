#!/bin/bash
# Actualizar paquetes
apt update -y
apt upgrade -y

# Instalar Docker
apt install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Instalar AWS CLI
apt install -y awscli

# Login en ECR (cambia <AWS_ACCOUNT_ID> y <REGION>)
