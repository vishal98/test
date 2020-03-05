resource "aws_lb" "cng_airflow_master" {
  name            = "${var.environment}-airflow-lb"
  security_groups = ["${aws_security_group.cng_airflow_sg.id}"]
  subnets         = ["${data.aws_subnet.app_subnet_2.id}", "${data.aws_subnet.app_subnet_1.id}"]
  internal        = true

  tags = merge(
    var.common_tags,
    map("Classification", "private"),
    map("Name", "${var.environment}-airflow-lb")
  )
}

resource "aws_lb_listener" "master_lb_listener" {
  load_balancer_arn = "${aws_lb.cng_airflow_master.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_iam_server_certificate.airflow_master_iam_crt.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.master_lb_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "master_lb_tg" {
  name     = "${var.environment}-airflow-master-lb-tg"
  port     = "8080"
  protocol = "HTTPS"
  vpc_id   = "${data.aws_vpc.cng.id}"

  health_check {
    path                = "/login/"
    port                = "8080"
    protocol            = "HTTPS"
    timeout             = "10"
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
  }

  tags = merge(
    var.common_tags,
    map("Classification", "private"),
    map("Name", "${var.environment}-airflow-master-lb-tg")
  )
}

resource "aws_lb_listener" "flower_lb_listener" {
  load_balancer_arn = "${aws_lb.cng_airflow_master.arn}"
  port              = "8443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_iam_server_certificate.airflow_master_iam_crt.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.flower_lb_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "flower_lb_tg" {
  name     = "${var.environment}-airflow-flower-lb"
  port     = "8443"
  protocol = "HTTPS"
  vpc_id   = "${data.aws_vpc.cng.id}"

  health_check {
    path                = "/"
    port                = "8443"
    protocol            = "HTTPS"
    timeout             = "10"
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
  }

  tags = merge(
    var.common_tags,
    map("Classification", "private"),
    map("Name", "${var.environment}-airflow-flower-lb-tg")
  )
}