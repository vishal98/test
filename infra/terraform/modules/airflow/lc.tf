


    

resource "aws_launch_configuration" "master_cng_lc" {
  name_prefix          = "${var.environment}-airflow-master-lc-"
  image_id             = "${data.aws_ami.master_cng_ami.id}"
  instance_type        = "${var.lc_master_instance_type}"
  key_name             = "${var.lc_key_name}"


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
  filter {
    name   = "name"
    values = ["Amazon Linux 2 AMI (HVM), SSD Volume Type *"]
  }

}


