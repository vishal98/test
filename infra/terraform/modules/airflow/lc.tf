locals {
  metric_tags = <<EOF
%{ for key in keys(var.common_tags) }${key}:${var.common_tags[key]} %{ endfor }
EOF
}

data "template_file" "airflow_master_user_data_template" {
  template = "${file("${path.module}/files/airflow_master_bootstrap.sh")}"

  vars = {
    RDS_USERNAME                  = "${var.rds_username}"
    RDS_PASSWORD                  = "${jsondecode(aws_secretsmanager_secret_version.secret.secret_string)["rds_password"]}"
    RDS_ENDPOINT                  = "${aws_db_instance.airflow.endpoint}"
    EFS_ENDPOINT_MASTER           = "${aws_efs_mount_target.master_cng_mt.0.ip_address}"
    PIP_REQS                      = file("../../../../src/requirements.txt")
    ENVIRONMENT                   = "${var.environment}"
    CODE_ENVIRONMENT              = split("-", var.environment)[length(split("-", var.environment)) - 1]
    CLOUDWATCH_LOGS               = "${aws_cloudwatch_log_group.airflow_log_group.name}"
    METRIC_TAGS                   = "${local.metric_tags}"
  }
}
    

data "template_file" "airflow_worker_user_data_template" {
  template = "${file("${path.module}/files/airflow_worker_bootstrap.sh")}"

  vars = {
    RDS_USERNAME                 = "${var.rds_username}"
    RDS_PASSWORD                 = "${aws_secretsmanager_secret_version.secret.secret_string}"
    RDS_ENDPOINT                 = "${aws_db_instance.airflow.endpoint}"
    EFS_ENDPOINT_WORKER          = "${aws_efs_mount_target.worker_cng_mt.0.ip_address}"
    PIP_REQS                     = file("../../../../src/requirements.txt")
    ENVIRONMENT                  = "${var.environment}"
    CODE_ENVIRONMENT             = split("-", var.environment)[length(split("-", var.environment)) - 1]
    CLOUDWATCH_LOGS              = "${aws_cloudwatch_log_group.airflow_log_group.name}"
    METRIC_TAGS                  = "${local.metric_tags}"
  }
}

resource "aws_launch_configuration" "master_cng_lc" {
  name_prefix          = "${var.environment}-airflow-master-lc-"
  image_id             = "${data.aws_ami.master_cng_ami.id}"
  instance_type        = "${var.lc_master_instance_type}"
  key_name             = "${var.lc_key_name}"
  security_groups      = ["${aws_security_group.cng_airflow_sg.id}"]
  user_data            = "${data.template_file.airflow_master_user_data_template.rendered}"

  iam_instance_profile = "arn:aws:iam::${var.account_id}:instance-profile/${var.iam_instance_profile}"

  root_block_device {
    volume_type           = "${var.lc_root_vl_type}"
    volume_size           = "${var.lc_root_vl_size}"
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "master_cng_ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["ca-cng-airflow-master-*"]
  }
  filter {
    name   = "tag:ami_version"
    values = ["${var.master_ami_version}"]
  }
}

resource "aws_launch_configuration" "worker_cng_lc" {
  name_prefix          = "${var.environment}-airflow-worker-lc-"
  image_id             = "${data.aws_ami.worker_cng_ami.id}"
  instance_type        = "${var.lc_worker_instance_type}"
  key_name             = "${var.lc_key_name}"
  security_groups      = ["${aws_security_group.cng_airflow_sg.id}"]
  user_data            = "${data.template_file.airflow_worker_user_data_template.rendered}"
  iam_instance_profile = "arn:aws:iam::${var.account_id}:instance-profile/${var.iam_instance_profile}"

  root_block_device {
    volume_type           = "${var.lc_root_vl_type}"
    volume_size           = "${var.lc_root_vl_size}"
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "worker_cng_ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["ca-cng-airflow-worker-*"]
  }
  filter {
    name   = "tag:ami_version"
    values = ["${var.worker_ami_version}"]
  }
}
