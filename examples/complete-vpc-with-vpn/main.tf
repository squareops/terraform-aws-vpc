locals {
  vpc_name                                       = "vpc-test"
  aws_region                                     = "ap-northeast-1"
  aws_account_id                                 = "767398031518"
  environment                                    = "prod"
  kms_user                                       = null
  vpc_cidr                                       = "10.10.0.0/16"
  vpc_availability_zones                         = ["ap-northeast-1a", "ap-northeast-1c"]
  kms_deletion_window_in_days                    = 7
  enable_key_rotation                            = false
  is_enabled                                     = true
  vpc_flow_log_enabled                           = false
  vpn_server_enabled                             = true
  vpc_intra_subnet_enabled                       = true
  vpc_public_subnet_enabled                      = true
  auto_assign_public_ip                          = true
  vpc_private_subnet_enabled                     = true
  vpc_one_nat_gateway_per_az                     = true
  vpc_database_subnet_enabled                    = true
  vpc_s3_endpoint_enabled                        = true
  vpc_ecr_endpoint_enabled                       = true
  vpn_server_instance_type                       = "t3a.small"
  vpc_flow_log_cloudwatch_log_group_skip_destroy = false
  current_identity                               = data.aws_caller_identity.current.arn
  multi_region                                   = false
  vpc_public_subnets_counts                      = 2
  vpc_private_subnets_counts                     = 2
  vpc_database_subnets_counts                    = 2
  vpc_intra_subnets_counts                       = 2
  additional_aws_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
  }
}

data "aws_caller_identity" "current" {}

module "key_pair_vpn" {
  source             = "squareops/keypair/aws"
  key_name           = format("%s-%s-vpn", local.environment, local.vpc_name)
  environment        = local.environment
  ssm_parameter_path = format("%s-%s-vpn", local.environment, local.vpc_name)
}

module "kms" {
  source = "terraform-aws-modules/kms/aws"

  deletion_window_in_days = local.kms_deletion_window_in_days
  description             = "Symetric Key to Enable Encryption at rest using KMS services."
  enable_key_rotation     = local.enable_key_rotation
  is_enabled              = local.is_enabled
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = local.multi_region

  # Policy
  enable_default_policy                  = true
  key_owners                             = [local.current_identity]
  key_administrators                     = local.kms_user == null ? ["arn:aws:iam::${local.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", "arn:aws:iam::${local.aws_account_id}:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS", local.current_identity] : local.kms_user
  key_users                              = local.kms_user == null ? ["arn:aws:iam::${local.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", "arn:aws:iam::${local.aws_account_id}:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS", local.current_identity] : local.kms_user
  key_service_users                      = local.kms_user == null ? ["arn:aws:iam::${local.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", "arn:aws:iam::${local.aws_account_id}:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS", local.current_identity] : local.kms_user
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
          identifiers = ["logs.${local.aws_region}.amazonaws.com"]
        }
      ]
    }
  ]
  # Aliases
  aliases                 = ["${local.vpc_name}-KMS"]
  aliases_use_name_prefix = true
}


module "vpc" {
  source                                              = "../../"
  name                                                = local.vpc_name
  aws_region                                          = local.aws_region
  vpc_cidr                                            = local.vpc_cidr
  environment                                         = local.environment
  vpc_flow_log_enabled                                = local.vpc_flow_log_enabled
  vpn_server_key_pair_name                            = module.key_pair_vpn.key_pair_name
  vpc_availability_zones                              = local.vpc_availability_zones
  vpn_server_enabled                                  = local.vpn_server_enabled
  vpc_intra_subnet_enabled                            = local.vpc_intra_subnet_enabled
  vpc_public_subnet_enabled                           = local.vpc_public_subnet_enabled
  auto_assign_public_ip                               = local.auto_assign_public_ip
  vpc_private_subnet_enabled                          = local.vpc_private_subnet_enabled
  vpc_one_nat_gateway_per_az                          = local.vpc_one_nat_gateway_per_az
  vpc_database_subnet_enabled                         = local.vpc_database_subnet_enabled
  vpn_server_instance_type                            = local.vpn_server_instance_type
  vpc_s3_endpoint_enabled                             = local.vpc_s3_endpoint_enabled
  vpc_ecr_endpoint_enabled                            = local.vpc_ecr_endpoint_enabled
  vpc_flow_log_max_aggregation_interval               = 60 # In seconds
  vpc_flow_log_cloudwatch_log_group_skip_destroy      = local.vpc_flow_log_cloudwatch_log_group_skip_destroy
  vpc_flow_log_cloudwatch_log_group_retention_in_days = 90
  vpc_flow_log_cloudwatch_log_group_kms_key_arn       = module.kms.key_arn #Enter your kms key arn
  vpc_public_subnets_counts                           = local.vpc_public_subnets_counts
  vpc_private_subnets_counts                          = local.vpc_private_subnets_counts
  vpc_database_subnets_counts                         = local.vpc_database_subnets_counts
  vpc_intra_subnets_counts                            = local.vpc_intra_subnets_counts
  vpc_endpoint_type_private_s3                        = "Gateway"
  vpc_endpoint_type_ecr_dkr                           = "Interface"
  vpc_endpoint_type_ecr_api                           = "Interface"
}
