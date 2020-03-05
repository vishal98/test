module "aws_af_ca" {
  source = "../../modules/airflow"

  ###### RDS Variables ######

  rds_engine_version            = "${var.rds_engine_version}"
  rds_instance_class            = "${var.rds_instance_class}"
  rds_allocated_storage         = "${var.rds_allocated_storage}"
  rds_storage_type              = "${var.rds_storage_type}"
  rds_username                  = "${var.rds_username}"
  environment                   = "${var.environment}"
  vpc_environment               = "${var.vpc_environment}"
  region                        = "${var.region}"
  account_id                    = "${var.account_id}"
  common_tags                   = "${var.common_tags}"
  rds_identifier                = "${var.rds_identifier}"
  aws_db_parameter_group_family = "${var.aws_db_parameter_group_family}"

  ###### Redis Variables ######

  redis_replication_group_id    = "${var.redis_replication_group_id}"
  redis_engine_version          = "${var.redis_engine_version}"
  redis_node_type               = "${var.redis_node_type}"
  redis_parameter_group_name    = "${var.redis_parameter_group_name}"

  ####### LC Variables ########

  lc_master_instance_type = "${var.lc_master_instance_type}"
  lc_worker_instance_type = "${var.lc_worker_instance_type}"
  lc_key_name             = "${var.lc_key_name}"
  lc_root_vl_type         = "${var.lc_root_vl_type}"
  lc_root_vl_size         = "${var.lc_root_vl_size}"
  iam_instance_profile    = "${var.iam_instance_profile}"

  availability_zones          = "${var.availability_zones}"
  asg_master_desired_capacity = "${var.asg_master_desired_capacity}"
  asg_master_max_size         = "${var.asg_master_max_size}"
  asg_master_min_size         = "${var.asg_master_min_size}"
  asg_worker_desired_capacity = "${var.asg_worker_desired_capacity}"
  asg_worker_max_size         = "${var.asg_worker_max_size}"
  asg_worker_min_size         = "${var.asg_worker_min_size}"

  ####### TLS Variables ########
  certificate_body = "${tls_self_signed_cert.public_cert.cert_pem}"
  private_key      = "${tls_private_key.key.private_key_pem}"

  master_ami_version = "${var.master_ami_version}"
  worker_ami_version = "${var.worker_ami_version}"
}
