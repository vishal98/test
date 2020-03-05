terraform {
  backend "s3" {
    bucket         = "ca-cng-dev-terraform-state-s3"
    dynamodb_table = "ca-cng-dev-terraform-state-lock"
    key            = "lrnthn/cng-airflow-dns/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    role_arn       = "arn:aws:iam::433485033485:role/ca_cng_jenkins"
  }
}