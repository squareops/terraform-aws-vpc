locals {
  vpc_peering_requester_route_tables_ids = data.aws_route_tables.requester.ids
  vpc_peering_accepter_route_tables_ids  = data.aws_route_tables.accepter.ids
}

provider "aws" {
  alias   = "peer"
  region  = var.vpc_peering_requester_region
  profile = var.vpc_peering_multi_account_enabled ? var.vpc_peering_requester_aws_profile : "default"
}

provider "aws" {
  alias   = "accepter"
  region  = var.vpc_peering_accepter_region
  profile = var.vpc_peering_multi_account_enabled ? var.vpc_peering_accepter_aws_profile : "default"
}

data "aws_vpc" "accepter" {
  id       = var.vpc_peering_accepter_id
  provider = aws.accepter
}

data "aws_route_tables" "accepter" {
  vpc_id   = var.vpc_peering_accepter_id
  provider = aws.accepter
}

data "aws_vpc" "requester" {
  id       = var.vpc_peering_requester_id
  provider = aws.peer
}

data "aws_route_tables" "requester" {
  vpc_id   = var.vpc_peering_requester_id
  provider = aws.peer
}

data "aws_caller_identity" "accepter" {
  provider = aws.accepter
}

resource "aws_vpc_peering_connection" "this" {
  count         = var.vpc_peering_enabled ? 1 : 0
  vpc_id        = var.vpc_peering_requester_id
  peer_vpc_id   = var.vpc_peering_accepter_id
  peer_region   = var.vpc_peering_multi_account_enabled ? var.vpc_peering_accepter_region : null
  auto_accept   = false
  peer_owner_id = var.vpc_peering_multi_account_enabled ? data.aws_caller_identity.accepter.id : null
  provider      = aws.peer
  tags = {
    Name = format("%s-%s-%s", var.vpc_peering_requester_name, "to", var.vpc_peering_accepter_name)
  }
}

resource "aws_vpc_peering_connection_accepter" "this" {
  count                     = var.vpc_peering_enabled ? 1 : 0
  depends_on                = [aws_vpc_peering_connection.this]
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.this[0].id
  auto_accept               = true
  tags = {
    Name = format("%s-%s-%s", var.vpc_peering_requester_name, "to", var.vpc_peering_accepter_name)
  }
}

resource "aws_vpc_peering_connection_options" "this" {
  count                     = var.vpc_peering_enabled ? 1 : 0
  depends_on                = [aws_vpc_peering_connection_accepter.this]
  vpc_peering_connection_id = aws_vpc_peering_connection.this[0].id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  provider = aws.accepter
}


####  route tables ####

resource "aws_route" "requester" {
  count                     = var.vpc_peering_enabled ? length(local.vpc_peering_requester_route_tables_ids) : 0
  route_table_id            = local.vpc_peering_requester_route_tables_ids[count.index]
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = var.vpc_peering_enabled ? aws_vpc_peering_connection.this[0].id : null
  provider                  = aws.peer
}

resource "aws_route" "accepter" {
  count                     = var.vpc_peering_enabled ? length(local.vpc_peering_accepter_route_tables_ids) : 0
  route_table_id            = local.vpc_peering_accepter_route_tables_ids[count.index]
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = var.vpc_peering_enabled ? aws_vpc_peering_connection.this[0].id : null
  provider                  = aws.accepter
}
