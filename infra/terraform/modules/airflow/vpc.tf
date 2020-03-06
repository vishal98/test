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

