variable "vpc_peering_accepter_id" {
  type        = string
  description = "Specify the unique identifier of the VPC that will act as the Acceptor in the VPC peering connection."
  default     = ""
}

variable "vpc_peering_accepter_region" {
  type        = string
  description = "Provide the AWS region where the Acceptor VPC is located. This helps in identifying the correct region for establishing the VPC peering connection."
  default     = ""
}

variable "vpc_peering_requester_id" {
  type        = string
  description = "Specify the unique identifier of the VPC that will act as the Reqester in the VPC peering connection."
  default     = ""
}

variable "vpc_peering_requester_region" {
  type        = string
  description = "Specify the AWS region where the Requester VPC resides. It ensures the correct region is used for setting up the VPC peering."
  default     = ""
}

variable "vpc_peering_requester_name" {
  type        = string
  description = "Provide a descriptive name or label for the VPC Requester. This helps identify and differentiate the Requester VPC in the peering connection."
  default     = ""
}

variable "vpc_peering_accepter_name" {
  type        = string
  description = "Assign a meaningful name or label to the VPC Accepter. This aids in distinguishing the Accepter VPC within the VPC peering connection."
  default     = ""
}

variable "vpc_peering_enabled" {
  type        = bool
  description = "Set this variable to true if you want to create the VPC peering connection. Set it to false if you want to skip the creation process."
  default     = true
}

variable "vpc_peering_multi_account_enabled" {
  type        = bool
  description = "Set this variable to true if you want to create the VPC peering connection between reagions. Set it to false if you want to skip the creation process."
  default     = true
}

variable "vpc_peering_requester_aws_profile" {
  type        = string
  description = "Provide the AWS profile where the requester VPC is located."
  default     = ""
}

variable "vpc_peering_accepter_aws_profile" {
  type        = string
  description = "Provide the AWS profile where the accepter VPC is located."
  default     = ""
}
