resource "aws_elasticache_replication_group" "cng_redis" {
  replication_group_description = "Airflow Cluster"
  replication_group_id          = "${var.environment}-${var.redis_replication_group_id}"
  engine                        = "redis"
  engine_version                = "${var.redis_engine_version}"
  node_type                     = "${var.redis_node_type}"
  port                          = 6379
  subnet_group_name             = "${aws_elasticache_subnet_group.cng-af-sg.name}"
  security_group_ids            = ["${aws_security_group.cng_airflow_sg.id}"]
  parameter_group_name          = "${var.redis_parameter_group_name}"
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  maintenance_window            = "sun:06:00-sun:07:00"
  auto_minor_version_upgrade    = false
  apply_immediately             = true
  number_cache_clusters         = 2

  automatic_failover_enabled = true

  tags = merge(
    var.common_tags,
    map("Classification", "private"),
    map("Name", "${var.environment}-airflow-redis")
  )
}

resource "aws_elasticache_subnet_group" "cng-af-sg" {
  name        = "${var.environment}-subnet-group-airflow"
  description = "Private subnets for the ElastiCache instances: airflow"
  subnet_ids  = ["${data.aws_subnet.data_subnet_0.id}", "${data.aws_subnet.data_subnet_1.id}", "${data.aws_subnet.data_subnet_2.id}"]
}
