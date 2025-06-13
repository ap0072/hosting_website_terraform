

module "multiple_ec2_instance_creation" {

  source = "./modules/multiple_ec2_instance"
  instance_data = var.instance_data #"t2.micro"


}

output "instance_public_ip" {
  value = module.multiple_ec2_instance_creation.public_ip
}
