provider "aws" {
  region = local.region
  default_tags {
    tags = local.additional_aws_tags
  }
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.99.1"
    }
  }
}
