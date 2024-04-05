provider "aws" {
  alias          = "peer"
  region         = "ap-northeast-1"
  aws_account_id = ""
  default_tags {
    tags = local.additional_tags
  }
}

provider "aws" {
  alias          = "accepter"
  region         = "ap-northeast-1"
  aws_account_id = ""
  default_tags {
    tags = local.additional_tags
  }
}
