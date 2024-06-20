locals {
  accepter_name    = "tenent-peering"
  accepter_region  = "us-east-1"
  accepter_vpc_id  = "vpc-07a2c1d0328341493"
  requester_name   = "management-peering"
  requester_region = "ap-northeast-1"
  requester_vpc_id = "vpc-0ce36808b9b133608"
  additional_tags = {
    Owner   = "tenent"
    Tenancy = "dedicated"
  }
}

module "vpc_peering" {
  source                            = "../../modules/vpc_peering"
  accepter_name                     = local.accepter_name
  vpc_peering_accepter_vpc_id       = local.accepter_vpc_id
  vpc_peering_accepter_vpc_region   = local.accepter_region
  requester_name                    = local.requester_name
  vpc_peering_requester_vpc_id      = local.requester_vpc_id
  vpc_peering_requester_vpc_region  = local.requester_region
  vpc_peering_multi_account_enabled = true
  vpc_peering_requester_aws_profile = "peer"
  vpc_peering_accepter_aws_profile  = "accepter"
}
