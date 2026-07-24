########################################
# Generate RSA Private Key
########################################

resource "tls_private_key" "kind_lab" {

  algorithm = "RSA"

  rsa_bits = 4096

}

########################################
# Save PEM File Locally
########################################

resource "local_file" "private_key" {

  filename = "${path.module}/${var.key_name}.pem"

  content = tls_private_key.kind_lab.private_key_pem

  file_permission = "0400"

}

########################################
# Upload Public Key to AWS
########################################

resource "aws_key_pair" "kind_lab" {

  key_name = var.key_name

  public_key = tls_private_key.kind_lab.public_key_openssh

}