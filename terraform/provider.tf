provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "kind-bluegreen-lab"
      Environment = "lab"
      owner       = "shubham"
      ManagedBy   = "Terraform"
      Terraform   = "true"
    }
  }
}
