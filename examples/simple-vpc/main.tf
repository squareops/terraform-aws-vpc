locals {
  region      = "us-east-1"
  environment = "dev"
  name        = "simple-example"
  additional_aws_tags = {
    Owner      = "SquareOps"
    Expires    = "Never"
    Department = "Engineering"
  }
  vpc_cidr = "172.10.0.0/16"
}

data "aws_availability_zones" "available" {}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "squareops/vpc/aws"

  environment          = local.environment
  name                 = local.name
  vpc_cidr             = local.vpc_cidr
  azs                  = [for n in range(0, 3) : data.aws_availability_zones.available.names[n]]
  enable_public_subnet = true
}
