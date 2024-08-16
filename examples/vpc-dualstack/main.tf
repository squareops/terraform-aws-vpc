locals {
  name        = "skaf"
  region      = "us-east-1"
  environment = "stage"
  additional_aws_tags = {
    Owner      = "SquareOps"
    Expires    = "Never"
    Department = "Engineering"
    Product    = "Atmosly"
    Environment = local.environment
  }
  vpc_cidr           = "10.10.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  ipv6_enabled       = true
}

module "vpc" {
  source                                          = "squareops/vpc/aws"
  name                                            = local.name
  vpc_cidr                                        = local.vpc_cidr
  environment                                     = local.environment
  availability_zones                              = local.availability_zones
  public_subnet_enabled                           = true
  private_subnet_enabled                          = true
  intra_subnet_enabled                            = false
  database_subnet_enabled                         = false
  auto_assign_public_ip                           = true
  ipv6_enabled                                    = local.ipv6_enabled
  public_subnet_assign_ipv6_address_on_creation   = true
  private_subnet_assign_ipv6_address_on_creation  = true
  database_subnet_assign_ipv6_address_on_creation = true
  intra_subnet_assign_ipv6_address_on_creation    = true

}
