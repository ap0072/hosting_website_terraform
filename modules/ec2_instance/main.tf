# Variables Demo


# Create an EC2 instance using the input variables
resource "aws_instance" "example_instance" {
  
  count        = var.create_instance ? 1 : 0
  ami           = var.ami_id
  instance_type = var.instance_type
}

# Define an output variable to expose the public IP address of the EC2 instance
#output "public_ip" {
#  description = "printing the count variable bolean value"
#  value       = aws_instance.example_instance.public_ip
#}

output "instance_public_ip" {
  description = "Public IP of the created EC2 instance"
  value       = var.create_instance ? aws_instance.example_instance[0].public_ip : ""
}

resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Example security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.environment == "production" ? [var.production_subnet_cidr] : [var.development_subnet_cidr]
  }
}
