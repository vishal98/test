environment        = "ca-cng-lrn_local"
vpc_environment    = "test-vpc-dev"
availability_zones = ["us-east-2b", "us-east-2a"]
region             = "us-east-2b"
common_tags = {
  TechnicalOwner = "ca_ops"
  Application    = "cng"
  Environment    = "development-integrated"
  Tier           = "orchestration"
  BusinessUnit   = "ca"
}
rds_identifier                = "airflow-lrn"
rds_instance_class            = "db.t2.small"
rds_engine_version            = "5.7"
rds_allocated_storage         = "10"
rds_storage_type              = "gp2"
rds_username                  = "airflow"
aws_db_parameter_group_family = "mysql5.7"


redis_replication_group_id    = "af-redis-lrn"
redis_engine_version          = "5.0.4"
redis_node_type               = "cache.t2.small"
redis_parameter_group_name    = "default.redis5.0"

lc_master_instance_type = "t2.small"
lc_worker_instance_type = "t2.small"
lc_key_name             = "test-local-dev"
lc_root_vl_type         = "gp2"
lc_root_vl_size         = "30"
iam_instance_profile    = "ca_cng_airflow"

app_certs_archive_path = "SSL_Certs"

asg_master_desired_capacity = "1"
asg_master_max_size         = "1"
asg_master_min_size         = "1"
asg_worker_desired_capacity = "1"
asg_worker_max_size         = "1"
asg_worker_min_size         = "1"

master_ami_version          = "2020-02-26"
worker_ami_version          = "2020-02-26"