# Allocate an Elastic IP (EIP) in the VPC
resource "aws_eip" "vpn" {
  domain   = "vpc"
  instance = module.vpn_server.id
}

# Security group created for VPN server EC2 instance
module "security_group_vpn" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.1.2"
  create      = true
  name        = format("%s-%s-%s", var.environment, var.name, "vpn-sg")
  description = "vpn server security group"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Public HTTPS access"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Public HTTP access"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 10150
      to_port     = 10150
      protocol    = "udp"
      description = "VPN Server Port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Port"
      cidr_blocks = var.vpc_cidr
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = tomap(
    {
      "Name"        = format("%s-%s-%s", var.environment, var.name, "vpn-sg")
      "Environment" = var.environment
    },
  )
}

# Data block for selecting AMI for VPN server
data "aws_ami" "ubuntu_22_ami" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Linux script to install pritunl vpn service.
data "template_file" "pritunl" {
  template = file("${path.module}/scripts/pritunl-vpn.sh")
}

# Get the current AWS Region
data "aws_region" "current" {}

# Module block for calling AWS module to create a VPN server.
module "vpn_server" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "5.2.1"
  name                        = format("%s-%s-%s", var.environment, var.name, "vpn-ec2-instance")
  ami                         = data.aws_ami.ubuntu_22_ami.image_id
  instance_type               = var.vpn_server_instance_type
  subnet_id                   = var.public_subnet
  key_name                    = var.vpn_key_pair
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.security_group_vpn.security_group_id]
  user_data                   = join("", data.template_file.pritunl[*].rendered)
  iam_instance_profile        = join("", aws_iam_instance_profile.vpn_SSM[*].name)


  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 20
      kms_key_id  = var.kms_key_arn
    }
  ]

  tags = tomap(
    {
      "Name"        = format("%s-%s-%s", var.environment, var.name, "vpn-ec2-instance")
      "Environment" = var.environment
    },
  )
}

# Define an IAM role for the VPN EC2 instance
resource "aws_iam_role" "vpn_role" {
  name               = format("%s-%s-%s", var.environment, var.name, "vpnEC2InstanceRole")
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Data resource to get ARN of SSM policy.
data "aws_iam_policy" "SSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Resource block to attach IAM policy with IAM role.
resource "aws_iam_role_policy_attachment" "SSMManagedInstanceCore_attachment" {
  role       = join("", aws_iam_role.vpn_role[*].name)
  policy_arn = data.aws_iam_policy.SSMManagedInstanceCore.arn
}

# Define an IAM instance profile for VPN EC2 instances
resource "aws_iam_instance_profile" "vpn_SSM" {
  name = format("%s-%s-%s", var.environment, var.name, "vpnEC2InstanceProfile")
  role = join("", aws_iam_role.vpn_role[*].name)
}

# Define a null_resource to introduce a delay of 3 minutes after module.vpn_server completes
resource "time_sleep" "wait_3_min" {
  depends_on      = [module.vpn_server]
  create_duration = "3m"
}

# Get the ARN for secret manager policy.
data "aws_iam_policy" "SecretsManagerReadWrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Attach IAM role policy for Secrets Manager read-write access
resource "aws_iam_role_policy_attachment" "SecretsManagerReadWrite_attachment" {
  role       = join("", aws_iam_role.vpn_role[*].name)
  policy_arn = data.aws_iam_policy.SecretsManagerReadWrite.arn
}

# Define an AWS Systems Manager (SSM) association
resource "aws_ssm_association" "ssm_association" {
  name       = aws_ssm_document.ssm_document.name
  depends_on = [time_sleep.wait_3_min]
  targets {
    key    = "InstanceIds"
    values = [module.vpn_server.id]
  }
}

# Define an AWS Systems Manager (SSM) document for creating secrets
resource "aws_ssm_document" "ssm_document" {
  name          = format("%s-%s-%s", var.environment, var.name, "ssm_document_create_secret")
  depends_on    = [time_sleep.wait_3_min]
  document_type = "Command"
  content       = <<DOC
  {
   "schemaVersion": "2.2",
   "description": "to create pritunl keys",
   "parameters": {
      "Message": {
         "type": "String",
         "description": "to store pritunl key and password",
         "default": ""
      }
   },
   "mainSteps": [
      {
         "action": "aws:runShellScript",
         "name": "example",
         "inputs": {
            "runCommand": [
               "SETUPKEY=$(sudo pritunl setup-key)",
               "sleep 60",
               "PASSWORD=$(sudo pritunl default-password | grep password | awk '{ print $2 }' | tail -n1)",
               "sleep 60",
               "VPN_HOST=${aws_eip.vpn.public_ip}",
               "aws secretsmanager create-secret --region ${data.aws_region.current.name} --name ${var.environment}-${var.name}-vpnp --secret-string \"{\\\"user\\\": \\\"pritunl\\\", \\\"password\\\": $PASSWORD, \\\"setup-key\\\": \\\"$SETUPKEY\\\", \\\"vpn_host\\\": \\\"$VPN_HOST\\\"}\""
            ]
         }
      }
   ]
}
DOC
}

# Define a null_resource to execute a local command for deleting a Secrets Manager secret
resource "null_resource" "delete_secret" {
  triggers = {
    environment = var.environment
    name        = var.name
    region      = data.aws_region.current.name
  }
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    aws secretsmanager delete-secret --secret-id ${self.triggers.environment}-${self.triggers.name}-vpn --force-delete-without-recovery --region ${self.triggers.region}
    EOT
  }
}
