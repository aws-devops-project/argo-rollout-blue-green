########################################
# AWS Configuration
########################################

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

########################################
# Existing Infrastructure
########################################

# variable "vpc_id" {
#   description = "Existing VPC ID"
#   type        = string
# }

# variable "public_subnet_id" {
#   description = "Existing Public Subnet ID"
#   type        = string
# }

########################################
# EC2 Configuration
########################################

variable "instance_name" {
  description = "EC2 Name"
  type        = string
  default     = "kind-bluegreen-lab"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.large"
}

variable "root_volume_size" {
  description = "Root EBS Volume Size (GB)"
  type        = number
  default     = 50
}

variable "ssh_username" {
  description = "Default SSH User"
  type        = string
  default     = "ubuntu"
}

########################################
# Spot Instance
########################################

variable "spot_instance" {
  description = "Launch EC2 as Spot Instance"
  type        = bool
  default     = true
}

variable "spot_type" {
  description = "Spot request type"
  type        = string
  default     = "one-time"
}

########################################
# Networking
########################################

variable "associate_public_ip" {
  description = "Associate Public IP"
  type        = bool
  default     = true
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH"
  type        = string
  default     = "0.0.0.0/0"
}

########################################
# Elastic IP
########################################

variable "create_eip" {
  description = "Allocate Elastic IP"
  type        = bool
  default     = false
}

########################################
# SSH Key
########################################

variable "key_name" {
  description = "AWS Key Pair Name"
  type        = string
  default     = "kind-bluegreen-key"
}

########################################
# Tags
########################################

variable "common_tags" {
  description = "Common Tags"
  type        = map(string)

  default = {
    Project     = "kind-bluegreen-lab"
    Environment = "Lab"
    Terraform   = "true"
  }
}




