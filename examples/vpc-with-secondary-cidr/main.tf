locals {
  name        = "skaf"
  region      = "us-east-1"
  environment = "stage"
  additional_aws_tags = {
    Owner      = "SquareOps"
    Expires    = "Never"
    Department = "Engineering"
  }
  vpc_cidr              = "10.10.0.0/16"
  secondry_cidr_enabled = true
  secondary_cidr_blocks = ["10.20.0.0/16"]
}

module "vpc" {
  source                  = "squareops/vpc/aws"
  name                    = local.name
  vpc_cidr                = local.vpc_cidr
  environment             = local.environment
  availability_zones      = ["us-east-1a", "us-east-1b"]
  public_subnet_enabled   = true
  private_subnet_enabled  = true
  auto_assign_public_ip   = true
  intra_subnet_enabled    = true
  database_subnet_enabled = true
  secondry_cidr_enabled   = local.secondry_cidr_enabled
  secondary_cidr_blocks   = local.secondary_cidr_blocks
}
