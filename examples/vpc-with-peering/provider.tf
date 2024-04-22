provider "aws" {
  region = local.accepter_region
  default_tags {
    tags = local.additional_tags
  }
}
