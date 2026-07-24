########################################
# EC2 Information
########################################

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.kind_lab.id
}

output "instance_public_ip" {
  description = "EC2 Public IP"
  value       = aws_instance.kind_lab.public_ip
}

output "instance_private_ip" {
  description = "EC2 Private IP"
  value       = aws_instance.kind_lab.private_ip
}

output "instance_public_dns" {
  description = "EC2 Public DNS"
  value       = aws_instance.kind_lab.public_dns
}

########################################
# SSH
########################################

output "ssh_command" {
  description = "SSH Command"

  value = "ssh -i ${path.module}/${var.key_name}.pem ${var.ssh_username}@${aws_instance.kind_lab.public_ip}"
}

########################################
# Security Group
########################################

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.kind_lab.id
}

########################################
# Default VPC
########################################

output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

########################################
# Subnet Used
########################################

output "public_subnet_id" {
  description = "Selected Public Subnet"
  value       = data.aws_subnets.default_public.ids[0]
}

########################################
# SSH Key
########################################

output "key_pair_name" {
  description = "AWS Key Pair"
  value       = aws_key_pair.kind_lab.key_name
}

output "private_key_file" {
  description = "Generated PEM File"

  value = "${path.module}/${var.key_name}.pem"
}

########################################
# Elastic IP
########################################

# output "elastic_ip" {

#   description = "Elastic IP"

#   value = var.create_eip ? aws_eip.kind_lab[0].public_ip : null

# }

########################################
# URLs
########################################

output "next_steps" {

  value = <<EOT

SSH
------------------------------------------------
ssh -i ${path.module}/${var.key_name}.pem ${var.ssh_username}@${aws_instance.kind_lab.public_ip}

After Kubernetes installation

Application
http://${aws_instance.kind_lab.public_ip}

ArgoCD
http://${aws_instance.kind_lab.public_ip}

Argo Rollouts
http://${aws_instance.kind_lab.public_ip}

EOT

}