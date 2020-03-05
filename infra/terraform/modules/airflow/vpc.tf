####################    VPC    ####################
data "aws_vpc" "cng" {
  tags = {
    Name = "${var.vpc_environment}-vpc"
  }
}

#################### APP Layer ####################
data "aws_subnet" "app_subnet_0" {
  vpc_id = "${data.aws_vpc.cng.id}"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_environment}-sub-pri-az1"]
  }
}

data "aws_subnet" "app_subnet_1" {
  vpc_id = "${data.aws_vpc.cng.id}"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_environment}-sub-pri-az2"]
  }
}
data "aws_subnet" "app_subnet_2" {
  vpc_id = "${data.aws_vpc.cng.id}"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_environment}-sub-pri-az3"]
  }
}

data "aws_subnet_ids" "cng-app" {
  vpc_id = "${data.aws_vpc.cng.id}"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_environment}-sub-pri-*"]
  }
}

data "aws_subnet_ids" "app_subnet" {
  vpc_id = "${data.aws_vpc.cng.id}"
  tags = {
    Name = "${var.vpc_environment}-sub-pri-*"
  }
}

#################### Data Layer ####################
data "aws_subnet" "data_subnet_0" {
  vpc_id = "${data.aws_vpc.cng.id}"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_environment}-sub-data-az1"]
  }
}

data "aws_subnet" "data_subnet_1" {
  vpc_id = "${data.aws_vpc.cng.id}"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_environment}-sub-data-az2"]
  }
}

data "aws_subnet" "data_subnet_2" {
  vpc_id = "${data.aws_vpc.cng.id}"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_environment}-sub-data-az3"]
  }
}

data "aws_subnet_ids" "cng-data" {
  vpc_id = "${data.aws_vpc.cng.id}"
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_environment}-sub-data-*"]
  }
}
