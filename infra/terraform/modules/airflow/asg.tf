resource "aws_autoscaling_group" "master_cng_asg" {
  availability_zones        = "${var.availability_zones}"
  name                      = "${aws_launch_configuration.master_cng_lc.name}-asg"
  launch_configuration      = "${aws_launch_configuration.master_cng_lc.name}"
  target_group_arns         = ["${aws_lb_target_group.master_lb_tg.arn}","${aws_lb_target_group.flower_lb_tg.arn}"]
  max_size                  = var.asg_master_max_size
  min_size                  = var.asg_master_min_size
  desired_capacity          = var.asg_master_desired_capacity
  health_check_grace_period = "300"
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["${data.aws_subnet.app_subnet_0.id}", "${data.aws_subnet.app_subnet_1.id}"]
  force_delete              = true

  lifecycle {
    create_before_destroy = true
  }

  enabled_metrics = var.asg_metrics

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = "true"
    }
  }
  tag {
    key                 = "Classification"
    value               = "private"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "Name"
    value               = "${var.environment}-airflow-master"
    propagate_at_launch = "true"
  }
}

resource "aws_autoscaling_group" "worker_cng_asg" {
  availability_zones        = "${var.availability_zones}"
  name                      = "${aws_launch_configuration.worker_cng_lc.name}-asg"
  launch_configuration      = "${aws_launch_configuration.worker_cng_lc.name}"
  max_size                  = var.asg_worker_max_size
  min_size                  = var.asg_worker_min_size
  desired_capacity          = var.asg_worker_desired_capacity
  health_check_grace_period = "300"
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["${data.aws_subnet.app_subnet_0.id}", "${data.aws_subnet.app_subnet_1.id}"]
  force_delete              = true

  lifecycle {
    create_before_destroy = true
  }

  enabled_metrics = var.asg_metrics

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = "true"
    }
  }
  tag {
    key                 = "Classification"
    value               = "private"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "Name"
    value               = "${var.environment}-airflow-worker"
    propagate_at_launch = "true"
  }

}