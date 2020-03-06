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

