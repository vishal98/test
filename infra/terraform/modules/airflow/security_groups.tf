#
# Security group resources
#
resource "aws_security_group" "cng_airflow_sg" {
  vpc_id                 = "${data.aws_vpc.cng.id}"
  description            = "${var.environment}-airflow-sg"
  revoke_rules_on_delete = true
  name                   = "${var.environment}-airflow-sg"

  tags = merge(
    var.common_tags,
    map("Classification", "private"),
    map("Name", "${var.environment}-airflow-sg")
  )
}
#
# Allow Airflow on 22 443 8443
#
resource "aws_security_group_rule" "airflow_sgr_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "TCP"
  self              = true
  description       = "Allow self security group"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}

resource "aws_security_group_rule" "airflow_sgr_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["10.33.0.0/16"]
  description       = "Allow Airflow to SSH"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}

resource "aws_security_group_rule" "airflow_sgr_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["10.33.0.0/16"]
  description       = "Allow Airflow on HTTPS"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}
resource "aws_security_group_rule" "airflow_sgr_8443" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "TCP"
  cidr_blocks       = ["10.33.0.0/16"]
  description       = "Allow Airflow on HTTPS"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}

resource "aws_security_group_rule" "airflow_sgr_8793" {
  type              = "ingress"
  from_port         = 8793
  to_port           = 8793
  protocol          = "TCP"
  cidr_blocks       = ["10.33.0.0/16"]
  description       = "Allow Airflow Worker log server on HTTP"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}

resource "aws_security_group_rule" "airflow_sgr_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "TCP"
  cidr_blocks       = ["10.136.94.0/23"]
  description       = "Allow Airflow on VPC"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}

resource "aws_security_group_rule" "airflow_sgr_cicd_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "TCP"
  cidr_blocks       = ["10.136.171.0/24"]
  description       = "Allow Airflow on VPC"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}

################### Temporary TUI Global Connect ##################
resource "aws_security_group_rule" "airflow_tui_global01_sgr_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["10.32.112.0/21"]
  description       = "TUI Global Protect Clients 443"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}
resource "aws_security_group_rule" "airflow_tui_global02_sgr_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["10.32.128.0/21"]
  description       = "TUI Global Protect Clients 443"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}

resource "aws_security_group_rule" "airflow_tui_global01_sgr_8443" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "TCP"
  cidr_blocks       = ["10.32.112.0/21"]
  description       = "TUI Global Protect Clients 8443"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}
resource "aws_security_group_rule" "airflow_sonata_rmr_sgr_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["10.174.0.0/16"]
  description       = "SONATA RMR 443"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}
resource "aws_security_group_rule" "airflow_sonata_rmr_sgr_22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "TCP"
  cidr_blocks              = ["10.174.0.0/22"]
  description              = "Allow SSH from Sonata RMR"
  security_group_id        = "${aws_security_group.cng_airflow_sg.id}"
}
resource "aws_security_group_rule" "airflow_tui_global02_sgr_8443" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "TCP"
  cidr_blocks       = ["10.32.128.0/21"]
  description       = "TUI Global Protect Clients 8443"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}

resource "aws_security_group_rule" "airflow_tui_global01_sgr_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["10.32.112.0/21"]
  description       = "TUI Global Protect Clients 22"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}
resource "aws_security_group_rule" "airflow_tui_global02_sgr_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["10.32.128.0/21"]
  description       = "TUI Global Protect Clients 22"
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}
######################################################################
resource "aws_security_group_rule" "airflow_sgre" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.cng_airflow_sg.id}"
}
