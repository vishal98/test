################################ Airflow Webserver ################################
resource "aws_iam_server_certificate" "airflow_master_iam_crt" {
  name             = "${var.environment}-airflow-master-iam-crt"
  certificate_body = "${var.certificate_body}"
  private_key      = "${var.private_key}"
}
