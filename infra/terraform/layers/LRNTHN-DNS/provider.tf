provider "aws" {
  region  = "${var.region}"
  version = "2.16.0"

  assume_role {
    role_arn = "arn:aws:iam::147860743096:role/ca_cng_jenkins"
  }
}