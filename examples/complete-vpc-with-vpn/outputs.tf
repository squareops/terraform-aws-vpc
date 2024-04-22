output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "AWS Region"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.vpc_public_subnets
}

output "vpc_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.vpc_private_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "vpc_intra_subnets" {
  description = "List of IDs of Intra subnets"
  value       = module.vpc.vpc_intra_subnets
}

output "vpn_host_public_ip" {
  description = "IP Adress of VPN Server"
  value       = module.vpc.vpn_host_public_ip
}

output "vpn_security_group" {
  description = "Security Group ID of VPN Server"
  value       = module.vpc.vpn_security_group
}
