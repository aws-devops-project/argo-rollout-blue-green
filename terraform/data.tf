########################################
# Get Default VPC
########################################

data "aws_vpc" "default" {
  default = true
}

########################################
# Get Default Public Subnet
########################################

data "aws_subnets" "default_public" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }

}
########################################
# Latest Ubuntu 24.04 LTS
########################################

data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}