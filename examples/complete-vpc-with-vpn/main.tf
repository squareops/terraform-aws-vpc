locals {
  name        = "vpc"
  region      = "us-west-1"
  environment = "prod"
  additional_aws_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
  }
  kms_user           = null
  vpc_cidr           = "10.10.0.0/16"
  availability_zones = ["us-west-1a", "us-west-1b"]
  current_identity   = data.aws_caller_identity.current.arn
  vpn_server_enabled = true // Set to true, enabling the VPN server within the VPC, which will use the provided key pair for securing VPN connections.
}

data "aws_caller_identity" "current" {}

module "key_pair_vpn" {
  source             = "squareops/keypair/aws"
  version            = "1.0.2"
  count              = local.vpn_server_enabled ? 1 : 0
  key_name           = format("%s-%s-vpn", local.environment, local.name)
  environment        = local.environment
  ssm_parameter_path = format("%s-%s-vpn", local.environment, local.name)
}

module "kms" {
  source                  = "terraform-aws-modules/kms/aws"
  version                 = "3.1.0"
  deletion_window_in_days = 7
  description             = "Symetric Key to Enable Encryption at rest using KMS services."
  enable_key_rotation     = false
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  # Policy
  enable_default_policy                  = true
  key_owners                             = [local.current_identity]
  key_administrators                     = local.kms_user == null ? ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS", local.current_identity] : local.kms_user
  key_users                              = local.kms_user == null ? ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS", local.current_identity] : local.kms_user
  key_service_users                      = local.kms_user == null ? ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS", local.current_identity] : local.kms_user
  key_symmetric_encryption_users         = [local.current_identity]
  key_hmac_users                         = [local.current_identity]
  key_asymmetric_public_encryption_users = [local.current_identity]
  key_asymmetric_sign_verify_users       = [local.current_identity]
  key_statements = [
    {
      sid    = "AllowCloudWatchLogsEncryption",
      effect = "Allow"
      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["logs.${local.region}.amazonaws.com"]
        }
      ]
    }
  ]
  # Aliases
  aliases                 = ["${local.name}-KMS"]
  aliases_use_name_prefix = true
}


module "vpc" {
  source                                          = "squareops/vpc/aws"
  version                                         = "3.3.5"
  name                                            = local.name
  region                                          = local.region
  vpc_cidr                                        = local.vpc_cidr
  environment                                     = local.environment
  flow_log_enabled                                = true
  vpn_key_pair_name                               = local.vpn_server_enabled ? module.key_pair_vpn[0].key_pair_name : null
  availability_zones                              = local.availability_zones
  vpn_server_enabled                              = local.vpn_server_enabled
  kms_key_arn                                     = module.kms.key_arn
  intra_subnet_enabled                            = true
  public_subnet_enabled                           = true
  auto_assign_public_ip                           = true
  private_subnet_enabled                          = true
  one_nat_gateway_per_az                          = true
  database_subnet_enabled                         = true
  vpn_server_instance_type                        = "t3a.small"
  vpc_s3_endpoint_enabled                         = true
  vpc_ecr_endpoint_enabled                        = true
  flow_log_max_aggregation_interval               = 60 # In seconds
  flow_log_cloudwatch_log_group_skip_destroy      = true
  flow_log_cloudwatch_log_group_retention_in_days = 90
  flow_log_cloudwatch_log_group_kms_key_arn       = module.kms.key_arn #Enter your kms key arn
}
