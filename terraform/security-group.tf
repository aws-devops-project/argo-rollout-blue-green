########################################
# Security Group
########################################

resource "aws_security_group" "kind_lab" {

  name        = "kind-bluegreen-sg"
  description = "Security Group for Kind Blue-Green Lab"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(
    var.common_tags,
    {
      Name = "kind-bluegreen-sg"
    }
  )
}

########################################
# SSH
########################################

resource "aws_vpc_security_group_ingress_rule" "ssh" {

  security_group_id = aws_security_group.kind_lab.id

  cidr_ipv4 = var.ssh_allowed_cidr

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"

  description = "SSH"
}

########################################
# HTTP (NGINX Ingress)
########################################

resource "aws_vpc_security_group_ingress_rule" "http" {

  security_group_id = aws_security_group.kind_lab.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"

  description = "HTTP"
}

########################################
# HTTPS (NGINX Ingress)
########################################

resource "aws_vpc_security_group_ingress_rule" "https" {

  security_group_id = aws_security_group.kind_lab.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"

  description = "HTTPS"
}

########################################
# Egress
########################################

resource "aws_vpc_security_group_egress_rule" "all" {

  security_group_id = aws_security_group.kind_lab.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}