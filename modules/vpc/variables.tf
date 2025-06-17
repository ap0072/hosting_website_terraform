# Define an input variable for the EC2 instance type
variable "region" {
  description = "VPC region to create"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_details" {}