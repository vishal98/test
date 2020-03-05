data "aws_api_gateway_rest_api" "le_rest_api" {
  name = "ca-cng-dev-logic-engine-packet-queue-proxy"
}

data "aws_api_gateway_rest_api" "wow_rest_api" {
  name = "ca-cng-dev-wow-tableData-api"
}