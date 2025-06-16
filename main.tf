/*

module "multiple_ec2_instance_creation" {

  source = "./modules/multiple_ec2_instance"
  instance_data = var.instance_data #"t2.micro"


}

output "instance_public_ip" {
  value = module.multiple_ec2_instance_creation.public_ip
}

*/

# Define the AWS provider configuration.
#provider "aws" {
#  region = "us-east-1"  # Replace with your desired AWS region.
#}

variable "cidr" {
  default = "11.0.0.0/16"
}

resource "aws_key_pair" "example" {
  key_name   = "terraform-demo"  # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key file
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "11.0.0.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

resource "aws_instance" "server" {
  ami                    = "ami-0f0c3baa60262d5b9"
  instance_type          = "m6i.xlarge"
  key_name      = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("~/.ssh/id_rsa")  # Replace with the path to your private key
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "app.py"  # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "virtual.zip"  # Replace with the path to your local file
    destination = "/home/ubuntu/virtual.zip"  # Replace with the path on the remote instance
  }


  provisioner "remote-exec" {
    inline = [
    	"sudo apt update -y",
	"sudo apt-get install -y software-properties-common",
	"sudo add-apt-repository universe -y",
	"sudo add-apt-repository multiverse -y",
	"sudo apt-get update -y",
	"sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unzip gcc",
        "curl https://pyenv.run | bash",

    	# Add pyenv env to profile
    	"echo 'export PATH=\"$HOME/.pyenv/bin:$PATH\"' >> ~/.bashrc",
    	"echo 'eval \"$(pyenv init --path)\"' >> ~/.bashrc",
    	"echo 'eval \"$(pyenv init -)\"' >> ~/.bashrc",
    	"echo 'eval \"$(pyenv virtualenv-init -)\"' >> ~/.bashrc",

    	# Load pyenv into current shell
    	"export PATH=\"$HOME/.pyenv/bin:$PATH\"",
    	"eval \"$(pyenv init --path)\"",
    	"eval \"$(pyenv init -)\"",
    	"eval \"$(pyenv virtualenv-init -)\"",

    	# Install and activate Python
    	"pyenv install 3.6.15",
    	"pyenv global 3.6.15",

    	# Setup and run app
    	"cd /home/ubuntu",
    	"unzip virtual.zip",
    	"pip install -r requirements.txt",
    	"python app.py"
]
}
}

output "ec2_public_ip" {
  value = aws_instance.server.public_ip
}


