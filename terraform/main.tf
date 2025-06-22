terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Crear clave SSH si no existe
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key-golang-cursor"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Módulo ECR
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
}

# Módulo IAM
module "iam" {
  source = "./modules/iam"
}

# Módulo Security Group
module "security_group" {
  source = "./modules/security-group"
  vpc_id = var.vpc_id
}

# Módulo EC2
module "ec2" {
  source               = "./modules/ec2"
  instance_type        = var.instance_type
  ami_id               = var.ami_id
  security_group       = module.security_group.security_group_id
  iam_instance_profile = module.iam.instance_profile_name
  key_name             = aws_key_pair.generated_key.key_name  # <- Asegurar que se pasa aquí
  user_data            = file("./scripts/user_data.sh")
}


# Módulo AWS SSM
module "ssm" {
  source      = "./modules/ssm"
  instance_id = module.ec2.instance_id
}
