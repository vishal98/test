locals {
  env_short = "${split("-", var.vpc_environment)[2]}"
}

data "aws_kms_key" "rds" {
  key_id = "alias/ca-${local.env_short}-rds"
}

data "aws_kms_key" "ebs" {
  key_id = "alias/ca-${local.env_short}-ebs"
}

data "aws_kms_key" "sm" {
  key_id = "alias/ca-${local.env_short}-sm"
}

data "aws_secretsmanager_secret" "af-users" {
  name = "ca-cng-airflow-users"
}

data "aws_secretsmanager_secret_version" "af-users-secret" {
  secret_id = "${data.aws_secretsmanager_secret.af-users.id}"
}