variable "rds_allocated_storage" {
  description = "The name of the allocated_storage"
}

variable "account_id" {
  description = "The AWS account ID"
}

variable "common_tags" {
  type = map(string)
}

variable "region" {
  description = "The name of the region"
}

variable "rds_storage_type" {
  description = "The name of the storage_type"
}

variable "rds_engine_version" {
  description = "mysql version of RDS instance"
}

variable "rds_instance_class" {
  description = "The name of the instance class"
}

variable "rds_identifier" {
  description = "The name of the rds_identifier"
}

variable "rds_username" {
  description = "The name of the rds_username"
}

variable "environment" {
  description = "TUI environment"
}

variable "vpc_environment" {
  description = "TUI VPC SBX environment"
}

variable "redis_replication_group_id" {
  description = "The name of the replication_group_id"
}

variable "redis_engine_version" {
  description = "mysql version of Redis instance"
}

variable "redis_node_type" {
  description = "The name of the node_type"
}

variable "redis_parameter_group_name" {
  description = "The name of the redis_parameter_group_name"
}

variable "app_certs_archive_path" {
  default = "app_certs_archive_path"
}

variable "lc_master_instance_type" {
  description = "The name of the instance type"
}

variable "lc_worker_instance_type" {
  description = "The name of the instance type"
}

variable "lc_key_name" {
  description = "The name of the key_name"
}

variable "lc_root_vl_type" {
  description = "The name of lc_root_vl_type"
}

variable "lc_root_vl_size" {
  description = "The name of lc_root_vl_size"
}

variable "aws_db_parameter_group_family" {
  description = "This is aws db parameter group family"
}

variable "availability_zones" {
  description = "Availability zones that are going to be used for the subnets"
  type        = "list"
}

variable "asg_master_desired_capacity" {
  description = "This is asg_desired_capacity"
}

variable "asg_master_min_size" {
  description = "This is asg_min_size"
}

variable "asg_master_max_size" {
  description = "This is asg_max_size"
}

variable "asg_worker_desired_capacity" {
  description = "This is asg_desired_capacity"
}

variable "asg_worker_min_size" {
  description = "This is asg_min_size"
}

variable "asg_worker_max_size" {
  description = "This is asg_max_size"
}

####### LC variable ########

variable "iam_instance_profile" {
  description = "The name of the iam_instance_profile"
}

variable "master_ami_version" {
  description = "The value of the 'ami_version' tag of the AMI to use for Airflow master"
}

variable "worker_ami_version" {
  description = "The value of the 'ami_version' tag of the AMI to use for Airflow workers"
}