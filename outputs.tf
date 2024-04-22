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
  value       = length(module.vpc.public_subnets) > 0 ? module.vpc.public_subnets : null
}

output "vpc_private_subnets" {
  description = "List of IDs of private subnets"
  value       = length(module.vpc.private_subnets) > 0 ? module.vpc.private_subnets : null
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = length(module.vpc.database_subnets) > 0 ? module.vpc.database_subnets : null
}

output "vpc_intra_subnets" {
  description = "List of IDs of Intra subnets"
  value       = length(module.vpc.intra_subnets) > 0 ? module.vpc.intra_subnets : null
}

output "vpn_host_public_ip" {
  description = "IP Adress of VPN Server"
  value       = var.vpn_server_enabled ? module.vpn_server[0].vpn_host_public_ip : null
}

output "vpn_security_group" {
  description = "Security Group ID of VPN Server"
  value       = var.vpn_server_enabled ? module.vpn_server[0].vpn_security_group : null
}
