locals {

  region          = "ap-south-1"
  name            = "gitops-eks-project"
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  tags = {
    Name = local.name
  }

}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Project     = local.name
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}
