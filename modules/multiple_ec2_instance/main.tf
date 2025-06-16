# Variables Demo


# Create an EC2 instance using the input variables
resource "aws_instance" "example_instance" {
  
  count        = "${length(var.instance_data)}"
  ami           = "${lookup(var.instance_data[count.index],"ami_id")}"
  instance_type = "${lookup(var.instance_data[count.index],"instance_type")}"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "terraform-statefile-storing-prasanthtech1234" # change this
}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "bucket_name" {
  description = "printing the s3 bucket name"
  #value       = [for instance in aws_instance.example_instance : instance.public_ip]
  value = "${aws_s3_bucket.s3_bucket.bucket}"
}



# Define an output variable to expose the public IP address of the EC2 instance
output "public_ip" {
  description = "printing the count variable bolean value"
  #value       = [for instance in aws_instance.example_instance : instance.public_ip]
  value = "${aws_instance.example_instance.*.public_ip}"
}

#output "instance_public_ip" {
#  description = "Public IP of the created EC2 instance"
#  value = create_instance?: aws_instance.example_instance[0].public_ip : ""
#}

#resource "aws_security_group" "example" {
#  name        = "example-sg"
#  description = "Example security group"
#
#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = var.environment == "production" ? [var.production_subnet_cidr] : [var.development_subnet_cidr]
#  }
#}
