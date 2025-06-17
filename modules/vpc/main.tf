resource "aws_vpc" "vpc" {
  region=var.region
  count        = "${length(var.vpc_details)}"
  cidr_block   = "${lookup(var.vpc_details[count.index],"cidr")}"
  tags = {
        Name = "${lookup(var.vpc_details[count.index],"name")}"
  }      
}