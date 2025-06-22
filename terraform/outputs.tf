output "ec2_public_ip" {
  description = "IP pública de la instancia EC2"
  value       = module.ec2.public_ip
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR"
  value       = module.ecr.repository_url
}

output "ssh_private_key" {
  description = "Clave privada SSH generada para acceder a la instancia"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssm_association_id" {
  description = "ID de la asociación SSM con EC2"
  value       = module.ssm.ssm_association_id
}

output "ec2_instance_id" {
  description = "ID de la instancia EC2"
  value       = module.ec2.instance_id
}