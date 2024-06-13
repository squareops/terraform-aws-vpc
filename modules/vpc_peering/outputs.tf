output "vpc_peering_connection_id" {
  description = "Peering connection ID"
  value       = var.vpc_peering_enabled ? aws_vpc_peering_connection.this[0].id : null
}

output "vpc_peering_accept_status" {
  description = "Status for the connection"
  value       = var.vpc_peering_enabled ? aws_vpc_peering_connection_accepter.this[0].accept_status : null
}
