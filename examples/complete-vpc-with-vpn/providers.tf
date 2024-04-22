provider "aws" {
  region = local.aws_region
  default_tags {
    tags = local.additional_aws_tags
  }
}
