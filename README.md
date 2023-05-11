# AWS Network Terraform module

![squareops_avatar]

[squareops_avatar]: https://squareops.com/wp-content/uploads/2022/12/squareops-logo.png

![RDS_avatar]
[RDS_avatar]: 
https://test-rds-image.s3.amazonaws.com/advance-tier-with-rds+(1).png

### [SquareOps Technologies](https://squareops.com/) Your DevOps Partner for Accelerating cloud journey.

<br>
Terraform module to create Networking resources for workload deployment on AWS Cloud.

## Usage Example

```hcl

module "key_pair_vpn" {
  source             = "squareops/keypair/aws"
  environment        = "production"
  key_name           = format("%s-%s-vpn", "production", "skaf")
  ssm_parameter_path = format("%s-%s-vpn", "production", "skaf")
}


module "vpc" {
  source = "squareops/vpc/aws"
  name                                            = "skaf"
  vpc_cidr                                        = "10.0.0.0/16"
  environment                                     = "production"
  flow_log_enabled                                = true
  vpn_key_pair_name                               = module.key_pair_vpn.key_pair_name
  availability_zones                              = 2
  vpn_server_enabled                              = false
  intra_subnet_enabled                            = true
  public_subnet_enabled                           = true
  private_subnet_enabled                          = true
  one_nat_gateway_per_az                          = true
  database_subnet_enabled                         = true
  vpn_server_instance_type                        = "t3a.small"
  flow_log_max_aggregation_interval               = 60
  flow_log_cloudwatch_log_group_retention_in_days = 90
}
```
Refer [this](https://github.com/squareops/terraform-aws-vpc/tree/main/examples) for more examples.


## Important Note
To prevent destruction interruptions, any resources that have been created outside of Terraform and attached to the resources provisioned by Terraform must be deleted before the module is destroyed.

The private key generated by Keypair module will be stored in AWS Systems Manager Parameter Store. For more details refer [this](https://registry.terraform.io/modules/squareops/keypair/aws)

## Network Scenarios

Users need to declare `vpc_cidr` and subnets are calculated with the help of in-built functions.

This module supports three scenarios to create Network resource on AWS. Each will be explained in brief in the corresponding sections.

- **simple-vpc (default behavior):** To create a VPC with public subnets and IGW.
  - `vpc_cidr       = ""`
  - `enable_public_subnet = true`
- **vpc-with-private-sub:** To create a VPC with public subnets, private subnets, IGW gateway and NAT gateway.
  - `vpc_cidr              = ""`
  - `public_subnet_enabled  = true`
  - `private_subnet_enabled = true`

- **complete-vpc-with-vpn:** To create a VPC with public, private, database and intra subnets along with an IGW and NAT gateway. Jump server/Bastion Host is also configured.
  - `vpc_cidr               = ""`
  - `public_subnet_enabled   = true`
  - `private_subnet_enabled  = true`
  - `database_subnet_enabled = true`
  - `intra_subnet_enabled    = true`
  - `one_nat_gateway_per_az = true`
  - `vpn_server_enabled     = true`
  - `vpn_server_instance_type = "t3a.small"`
  - `vpn_key_pair             = ""`
  - `flow_log_enabled          = true`
  - `flow_log_max_aggregation_interval               = 60`
  - `flow_log_cloudwatch_log_group_retention_in_days = 90`

- **vpc-peering:** VPC peering support is available using submodule `vpc_peering`. Refer [Peering Docs](https://github.com/squareops/terraform-aws-vpc/tree/main/modules/vpc_peering) for more information

# IAM Permissions
The required IAM permissions to create resources from this module can be found [here](https://github.com/squareops/terraform-aws-vpc/blob/main/IAM.md)



# VPN setup-
To configure Pritunl VPN:

      1. Access the Pritunl UI over HTTPS using the public IP of EC2 instance in browser
      2. Retrieve the initial key, user and password for setting up Pritunl from AWS Secrets Manager and log in to Pritunl.
      3. Create a DNS record mapping to the EC2 instance's public IP
      4. After login, in the Initial setup window, add the record created in the 'Lets Encrypt Domain' field.
      5. Pritunl will automatically configure a signed SSL certificate from Lets Encrypt.
      6. Add organization and user to pritunl.
      7. Add server and set port as 10150 which is already allowed from security group while creating instance for VPN server.
      8. Attach organization to the server and Start the server.
      9. Copy or download user profile link or file.
     10. Import the profile in Pritunl client.

    NOTE: Port 80 should be open publicly in the vpn security group to verify and renewing the domain certificate.


## CIS COMPLIANCE [<img src="	https://prowler.pro/wp-content/themes/prowler-pro/assets/img/logo.svg" width="250" align="right" />](https://prowler.pro/)

Security scanning is graciously provided by Prowler. Prowler is the leading fully hosted, cloud-native solution providing continuous cluster security and compliance.

| Benchmark | Description |
|--------|---------------|
| Ensure no security groups allow ingress from 0.0.0.0/0 or ::/0 to port 3389 | No Security Groups open to 0.0.0.0/0 |
| Ensure the default security group of every VPC restricts all traffic | No Default Security Groups open to 0.0.0.0/0 |


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.23 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.14.4 |
| <a name="module_vpn_server"></a> [vpn\_server](#module\_vpn\_server) | ./modules/vpn | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_ec2_instance_type.arch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Number of Availability Zone to be used by VPC Subnets | `number` | `2` | no |
| <a name="input_database_subnet_cidrs"></a> [database\_subnet\_cidrs](#input\_database\_subnet\_cidrs) | Database Tier subnet CIDRs to be created | `list(any)` | `[]` | no |
| <a name="input_database_subnet_enabled"></a> [database\_subnet\_enabled](#input\_database\_subnet\_enabled) | Set true to enable database subnets | `bool` | `false` | no |
| <a name="input_default_network_acl_ingress"></a> [default\_network\_acl\_ingress](#input\_default\_network\_acl\_ingress) | List of maps of ingress rules to set on the Default Network ACL | `list(map(string))` | <pre>[<br>  {<br>    "action": "deny",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 22,<br>    "protocol": "tcp",<br>    "rule_no": 98,<br>    "to_port": 22<br>  },<br>  {<br>    "action": "deny",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 3389,<br>    "protocol": "tcp",<br>    "rule_no": 99,<br>    "to_port": 3389<br>  },<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  },<br>  {<br>    "action": "allow",<br>    "from_port": 0,<br>    "ipv6_cidr_block": "::/0",<br>    "protocol": "-1",<br>    "rule_no": 101,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Specify the environment indentifier for the VPC | `string` | `""` | no |
| <a name="input_flow_log_cloudwatch_log_group_retention_in_days"></a> [flow\_log\_cloudwatch\_log\_group\_retention\_in\_days](#input\_flow\_log\_cloudwatch\_log\_group\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group for VPC flow logs. | `number` | `null` | no |
| <a name="input_flow_log_enabled"></a> [flow\_log\_enabled](#input\_flow\_log\_enabled) | Whether or not to enable VPC Flow Logs | `bool` | `false` | no |
| <a name="input_flow_log_max_aggregation_interval"></a> [flow\_log\_max\_aggregation\_interval](#input\_flow\_log\_max\_aggregation\_interval) | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds. | `number` | `60` | no |
| <a name="input_intra_subnet_cidrs"></a> [intra\_subnet\_cidrs](#input\_intra\_subnet\_cidrs) | A list of intra subnets CIDR to be created | `list(any)` | `[]` | no |
| <a name="input_intra_subnet_enabled"></a> [intra\_subnet\_enabled](#input\_intra\_subnet\_enabled) | Set true to enable intra subnets | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Specify the name of the VPC | `string` | `""` | no |
| <a name="input_one_nat_gateway_per_az"></a> [one\_nat\_gateway\_per\_az](#input\_one\_nat\_gateway\_per\_az) | Set to true if a NAT Gateway is required per availability zone for Private Subnet Tier | `bool` | `false` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | A list of private subnets CIDR to be created inside the VPC | `list(any)` | `[]` | no |
| <a name="input_private_subnet_enabled"></a> [private\_subnet\_enabled](#input\_private\_subnet\_enabled) | Set true to enable private subnets | `bool` | `false` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | A list of public subnets CIDR to be created inside the VPC | `list(any)` | `[]` | no |
| <a name="input_public_subnet_enabled"></a> [public\_subnet\_enabled](#input\_public\_subnet\_enabled) | Set true to enable public subnets | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block of the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpn_key_pair_name"></a> [vpn\_key\_pair\_name](#input\_vpn\_key\_pair\_name) | Specify the name of AWS Keypair to be used for VPN Server | `string` | `""` | no |
| <a name="input_vpn_server_enabled"></a> [vpn\_server\_enabled](#input\_vpn\_server\_enabled) | Set to true if you want to deploy VPN Gateway resource and attach it to the VPC | `bool` | `false` | no |
| <a name="input_vpn_server_instance_type"></a> [vpn\_server\_instance\_type](#input\_vpn\_server\_instance\_type) | EC2 instance Type for VPN Server, Only amd64 based instance type are supported eg. t2.medium, t3.micro, c5a.large etc. | `string` | `"t3a.small"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of IDs of database subnets |
| <a name="output_intra_subnets"></a> [intra\_subnets](#output\_intra\_subnets) | List of IDs of Intra subnets |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | IPV4 CIDR Block for this VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpn_host_public_ip"></a> [vpn\_host\_public\_ip](#output\_vpn\_host\_public\_ip) | IP Address of VPN Server |
| <a name="output_vpn_security_group"></a> [vpn\_security\_group](#output\_vpn\_security\_group) | Security Group ID of VPN Server |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contribute & Issue Report

To report an issue with a project:

  1. Check the repository's [issue tracker](https://github.com/squareops/terraform-aws-vpc/issues) on GitHub
  2. Search to check if the issue has already been reported
  3. If you can't find an answer to your question in the documentation or issue tracker, you can ask a question by creating a new issue. Make sure to provide enough context and details.

## License

Apache License, Version 2.0, January 2004 (https://www.apache.org/licenses/LICENSE-2.0)

## Support Us

To support our GitHub project by liking it, you can follow these steps:

  1. Visit the repository: Navigate to the [GitHub repository](https://github.com/squareops/terraform-aws-vpc)

  2. Click the "Star" button: On the repository page, you'll see a "Star" button in the upper right corner. Clicking on it will star the repository, indicating your support for the project.

  3. Optionally, you can also leave a comment on the repository or open an issue to give feedback or suggest changes.

Staring a repository on GitHub is a simple way to show your support and appreciation for the project. It also helps to increase the visibility of the project and make it more discoverable to others.

## Who we are

We believe that the key to success in the digital age is the ability to deliver value quickly and reliably. That’s why we offer a comprehensive range of DevOps & Cloud services designed to help your organization optimize its systems & Processes for speed and agility.

  1. We are an AWS Advanced consulting partner which reflects our deep expertise in AWS Cloud and helping 100+ clients over the last 5 years.
  2. Expertise in Kubernetes and overall container solution helps companies expedite their journey by 10X.
  3. Infrastructure Automation is a key component to the success of our Clients and our Expertise helps deliver the same in the shortest time.
  4. DevSecOps as a service to implement security within the overall DevOps process and helping companies deploy securely and at speed.
  5. Platform engineering which supports scalable,Cost efficient infrastructure that supports rapid development, testing, and deployment.
  6. 24*7 SRE service to help you Monitor the state of your infrastructure and eradicate any issue within the SLA.

We provide [support](https://squareops.com/contact-us/) on all of our projects, no matter how small or large they may be.

To find more information about our company, visit [squareops.com](https://squareops.com/), follow us on [Linkedin](https://www.linkedin.com/company/squareops-technologies-pvt-ltd/), or fill out a [job application](https://squareops.com/careers/). If you have any questions or would like assistance with your cloud strategy and implementation, please don't hesitate to [contact us](https://squareops.com/contact-us/).
