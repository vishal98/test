resource "aws_efs_file_system" "master_cng_efs" {
  creation_token   = "${var.environment}-airflow-master"
  performance_mode = "generalPurpose"
  kms_key_id       = "${data.aws_kms_key.ebs.arn}"
  encrypted        = "true"

  tags = merge(
    var.common_tags,
    map("Classification", "private"),
    map("Name", "${var.environment}-airflow-master-efs")
  )
}

resource "aws_efs_mount_target" "master_cng_mt" {
  file_system_id  = "${aws_efs_file_system.master_cng_efs.id}"
  count           = "${length(var.availability_zones)}"
  subnet_id       = "${element(tolist(data.aws_subnet_ids.cng-app.ids), count.index)}"
  security_groups = ["${aws_security_group.cng_airflow_sg.id}"]
}

resource "aws_efs_file_system" "worker_cng_efs" {
  creation_token   = "${var.environment}-airflow-worker"
  performance_mode = "generalPurpose"
  kms_key_id       = "${data.aws_kms_key.ebs.arn}"
  encrypted        = "true"

  tags = merge(
    var.common_tags,
    map("Classification", "private"),
    map("Name", "${var.environment}-airflow-worker-efs")
  )
}

resource "aws_efs_mount_target" "worker_cng_mt" {
  file_system_id  = "${aws_efs_file_system.worker_cng_efs.id}"
  count           = "${length(var.availability_zones)}"
  subnet_id       = "${element(tolist(data.aws_subnet_ids.cng-app.ids), count.index)}"
  security_groups = ["${aws_security_group.cng_airflow_sg.id}"]
}
