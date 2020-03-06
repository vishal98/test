




resource "aws_launch_configuration" "master_cng_lc" {
  name_prefix          = "${var.environment}-airflow-master-lc-"
  image_id             = "${data.aws_ami.master_cng_ami.id}"
  instance_type        = "${var.lc_master_instance_type}"
  security_groups      = ["${aws_security_group.cng_airflow_sg.id}"]


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
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20200207.1-x86_64-gp2"]
  }

}
