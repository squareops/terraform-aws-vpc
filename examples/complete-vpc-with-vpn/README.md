# Complete VPC with VPN

This configuration is suitable for production environments

NAT Gateways, public, database,intra and Private subnets will be created in each availability zone. Additionally by default, an EC2 instance which will act as a VPN server will be created.


## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_pair_vpn"></a> [key\_pair\_vpn](#module\_key\_pair\_vpn) | squareops/keypair/aws | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of IDs of database subnets |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | AWS Region |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_intra_subnets"></a> [vpc\_intra\_subnets](#output\_vpc\_intra\_subnets) | List of IDs of Intra subnets |
| <a name="output_vpc_private_subnets"></a> [vpc\_private\_subnets](#output\_vpc\_private\_subnets) | List of IDs of private subnets |
| <a name="output_vpc_public_subnets"></a> [vpc\_public\_subnets](#output\_vpc\_public\_subnets) | List of IDs of public subnets |
| <a name="output_vpn_host_public_ip"></a> [vpn\_host\_public\_ip](#output\_vpn\_host\_public\_ip) | IP Adress of VPN Server |
| <a name="output_vpn_security_group"></a> [vpn\_security\_group](#output\_vpn\_security\_group) | Security Group ID of VPN Server |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
