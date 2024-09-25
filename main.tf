provider "aws" { }

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "sg_ip_ingress_cidr_block" {}
variable "instance_type" {}
variable "ssh_public_key_location" {}

# create custom VPC
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

# create custom Subnet
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
}

# create Internet Gateway
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
      tags = {
      Name: "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table" "myapp-main-default-route-table" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0" # any ip address
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}

# create security group
resource "aws_default_security_group" "myapp-default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id # associate vpc with sg 
  # incoming traffic
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [var.sg_ip_ingress_cidr_block]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0 # any port
    to_port = 0
    protocol = "-1" # any protocol
    cidr_blocks = ["0.0.0.0/0"] # any
    prefix_list_ids = []
  }

  tags = {
    Name: "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami_id" {
  value= data.aws_ami.latest-amazon-linux-image
}

resource "aws_key_pair" "myapp-ssh-key" {
  key_name = "server-key"
  public_key = file(var.ssh_public_key_location)
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.myapp-default-sg.id]
  availability_zone = var.avail_zone
  # to access this from browser and ssh need a public ip
  associate_public_ip_address = true
  # keys
  key_name = aws_key_pair.myapp-ssh-key.key_name
  tags = {
    Name: "${var.env_prefix}-server"
  }
  # entry-point script that gets executed when ec2 instance whenever the server is instanciated
  user_data = file("entry-script.sh")

  user_data_replace_on_change = true
}