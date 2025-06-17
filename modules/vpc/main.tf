resource "aws_vpc" "vpc" {
  
  count        = "${length(var.vpc_details)}"
  cidr_block   = "${lookup(var.vpc_details[count.index],"cidr")}"
  tags = {
        Name = "${lookup(var.vpc_details[count.index],"name")}"
  }      
}