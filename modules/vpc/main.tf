resource "aws_vpc" "vpc" {
  region=var.region
  count        = "${length(var.vpc_details)}"
  cidr_block   = "${lookup(var.instance_data[count.index],"cidr")}"
  name         = "${lookup(var.instance_data[count.index],"name")}"       
}