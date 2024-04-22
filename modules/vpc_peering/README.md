# VPC Peering

Module to create a VPC peering connection between two VPCs. Routes are also added to the route tables of both VPC to establish connection with peered VPC. Public DNS hostnames will be resolved to private IP addresses when queried from instances in the peer VPC.

Supported peering configurations:
* Same account same region
* Same account cross region

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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.accepter"></a> [aws.accepter](#provider\_aws.accepter) | >= 4.23 |
| <a name="provider_aws.peer"></a> [aws.peer](#provider\_aws.peer) | >= 4.23 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route.accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.requester](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_vpc_peering_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_caller_identity.accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_route_tables.accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_route_tables.requester](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_vpc.accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.requester](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_peering_accepter_aws_profile"></a> [vpc\_peering\_accepter\_aws\_profile](#input\_vpc\_peering\_accepter\_aws\_profile) | Provide the AWS profile where the accepter VPC is located. | `string` | `""` | no |
| <a name="input_vpc_peering_accepter_id"></a> [vpc\_peering\_accepter\_id](#input\_vpc\_peering\_accepter\_id) | Specify the unique identifier of the VPC that will act as the Acceptor in the VPC peering connection. | `string` | `""` | no |
| <a name="input_vpc_peering_accepter_name"></a> [vpc\_peering\_accepter\_name](#input\_vpc\_peering\_accepter\_name) | Assign a meaningful name or label to the VPC Accepter. This aids in distinguishing the Accepter VPC within the VPC peering connection. | `string` | `""` | no |
| <a name="input_vpc_peering_accepter_region"></a> [vpc\_peering\_accepter\_region](#input\_vpc\_peering\_accepter\_region) | Provide the AWS region where the Acceptor VPC is located. This helps in identifying the correct region for establishing the VPC peering connection. | `string` | `""` | no |
| <a name="input_vpc_peering_enabled"></a> [vpc\_peering\_enabled](#input\_vpc\_peering\_enabled) | Set this variable to true if you want to create the VPC peering connection. Set it to false if you want to skip the creation process. | `bool` | `true` | no |
| <a name="input_vpc_peering_multi_account_enabled"></a> [vpc\_peering\_multi\_account\_enabled](#input\_vpc\_peering\_multi\_account\_enabled) | Set this variable to true if you want to create the VPC peering connection between reagions. Set it to false if you want to skip the creation process. | `bool` | `true` | no |
| <a name="input_vpc_peering_requester_aws_profile"></a> [vpc\_peering\_requester\_aws\_profile](#input\_vpc\_peering\_requester\_aws\_profile) | Provide the AWS profile where the requester VPC is located. | `string` | `""` | no |
| <a name="input_vpc_peering_requester_id"></a> [vpc\_peering\_requester\_id](#input\_vpc\_peering\_requester\_id) | Specify the unique identifier of the VPC that will act as the Reqester in the VPC peering connection. | `string` | `""` | no |
| <a name="input_vpc_peering_requester_name"></a> [vpc\_peering\_requester\_name](#input\_vpc\_peering\_requester\_name) | Provide a descriptive name or label for the VPC Requester. This helps identify and differentiate the Requester VPC in the peering connection. | `string` | `""` | no |
| <a name="input_vpc_peering_requester_region"></a> [vpc\_peering\_requester\_region](#input\_vpc\_peering\_requester\_region) | Specify the AWS region where the Requester VPC resides. It ensures the correct region is used for setting up the VPC peering. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_peering_accept_status"></a> [vpc\_peering\_accept\_status](#output\_vpc\_peering\_accept\_status) | Status for the connection |
| <a name="output_vpc_peering_connection_id"></a> [vpc\_peering\_connection\_id](#output\_vpc\_peering\_connection\_id) | Peering connection ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
