output "airflow_autoscaling_group_name_master" {
  value = aws_autoscaling_group.master_cng_asg.name
}

output "airflow_autoscaling_group_name_worker" {
  value = aws_autoscaling_group.worker_cng_asg.name
}

output "airflow_redis_endpoint_address" {
  value = "${aws_elasticache_replication_group.cng_redis.primary_endpoint_address}"
}

output "aws_cloudwatch_log_group_name" {
  value = "${aws_cloudwatch_log_group.airflow_log_group.name}"
}

output "aws_cloudwatch_startuplogs_group_name" {
  value = "${aws_cloudwatch_log_group.airflow_startup_logs_group.name}"
}

output "airflow_rds_endpoint" {
  value       = "${aws_db_instance.airflow.endpoint}"
  description = "RDS endpoint"
}

output "lb_dns_name" {
  value = aws_lb.cng_airflow_master.dns_name
}

output "lb_zone_id" {
  value = aws_lb.cng_airflow_master.zone_id
}

output "rds_password" {
  value = jsondecode(aws_secretsmanager_secret_version.secret.secret_string)["rds_password"]
}

output "af_ui_password" {
  value = jsondecode(data.aws_secretsmanager_secret_version.af-users-secret.secret_string)["admin"]
}

