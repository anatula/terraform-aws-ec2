provider "aws" { }

# create custom VPC
resource "aws_vpc" "myapp-vpc" {
  enable_dns_hostnames = true
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  sg_ip_ingress_cidr_block = var.sg_ip_ingress_cidr_block
  env_prefix = var.env_prefix
  image_name = var.image_name
  ssh_public_key_location = var.ssh_public_key_location
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id
  avail_zone = var.avail_zone
}

resource "ansible_host" "myapp-server" {
  name   = module.myapp-server.ec2_public_dns
  groups = ["ansible_client"]
  variables = {
    ansible_user                 = "ec2-user",
    ansible_ssh_private_key_file = "~/.ssh/aws_ec2_terraform",
    prefix                       = "${var.env_prefix}-server"
  }
  depends_on = [module.myapp-server]
}