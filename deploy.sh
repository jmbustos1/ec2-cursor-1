#!/bin/bash

# Configuración (Lee de variables de entorno)
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:?Variable AWS_ACCOUNT_ID no definida}"
ECR_REPOSITORY="${ECR_REPOSITORY:-ec2-cursor}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
EC2_INSTANCE_ID="${EC2_INSTANCE_ID:?Variable EC2_INSTANCE_ID no definida}"


COMPOSE_CONTENT=$(base64 -w0 docker-compose.yml)

# 1️⃣ **Login en ECR**
echo "🔑 Autenticando en AWS ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 2️⃣ **Construcción y subida de la imagen**
echo "🐳 Construyendo la imagen Docker..."
docker build -t $ECR_REPOSITORY .
echo "🏷 Etiquetando imagen..."
docker tag $ECR_REPOSITORY:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
echo "📤 Subiendo imagen a AWS ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG

# 3️⃣ **Ejecutar en EC2 vía SSM**
echo "🚀 Desplegando en EC2 a través de AWS SSM..."

aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --targets "[{\"Key\":\"instanceids\",\"Values\":[\"$EC2_INSTANCE_ID\"]}]" \
    --parameters "commands=[
      \"echo $COMPOSE_CONTENT | base64 -d > /home/ubuntu/docker-compose.yml\",
      \"/usr/bin/aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com >> /tmp/deploy.log 2>&1\",
      \"docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG >> /tmp/deploy.log 2>&1\",
      \"docker compose -f /home/ubuntu/docker-compose.yml down >> /tmp/deploy.log 2>&1\",
      \"docker compose -f /home/ubuntu/docker-compose.yml up -d >> /tmp/deploy.log 2>&1\"
    ]" \
    --region $AWS_REGION

echo "✅ Despliegue iniciado en EC2. Verifica la instancia en AWS."


