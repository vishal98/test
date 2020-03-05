# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "airflow_log_group" {
  name              = "${var.environment}-airflow-log-group"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "airflow_startup_logs_group" {
  name              = "${var.environment}-airflow-startup-logs-group"
  retention_in_days = 30
}