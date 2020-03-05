output "airflow_redis_endpoint_address" {
  value = module.aws_af_ca.airflow_redis_endpoint_address
}

output "airflow_rds_endpoint" {
  value = module.aws_af_ca.airflow_rds_endpoint
}

output "airflow_master_asg_name" {
  value = module.aws_af_ca.airflow_autoscaling_group_name_master
}

output "airflow_worker_asg_name" {
  value = module.aws_af_ca.airflow_autoscaling_group_name_worker
}

output "lb_dns_name" {
  value = module.aws_af_ca.lb_dns_name
}

output "lb_zone_id" {
  value = module.aws_af_ca.lb_zone_id
}

output "rds_username" {
  value = var.rds_username
}

output "rds_password" {
  value = module.aws_af_ca.rds_password
}

output "af_ui_password" {
  value = module.aws_af_ca.af_ui_password
}



output "aws_cloudwatch_log_group_name" {
  value = module.aws_af_ca.aws_cloudwatch_log_group_name
}

output "aws_cloudwatch_startuplogs_group_name" {
  value = module.aws_af_ca.aws_cloudwatch_startuplogs_group_name
}

output "packet_queue_api" {
  value = "https://${data.aws_api_gateway_rest_api.le_rest_api.id}.execute-api.${var.region}.amazonaws.com/${var.environment}/api"
}

output "wow_tabledata_api" {
  value = "https://${data.aws_api_gateway_rest_api.wow_rest_api.id}.execute-api.${var.region}.amazonaws.com/${var.environment}/tableData"
}

output "environment_name" {
  value = var.common_tags["Environment"]
}