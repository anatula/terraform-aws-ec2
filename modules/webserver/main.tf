# retrieve our public ip 
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}
# create security group
resource "aws_default_security_group" "myapp-default-sg" {
  vpc_id = var.vpc_id # associate vpc with sg 
  # incoming traffic
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    # cidr_blocks = [var.sg_ip_ingress_cidr_block]
    # chomp() method to remove any trailing space or new line which comes with body
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
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
    values = [var.image_name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "myapp-ssh-key" {
  key_name = "server-key"
  public_key = file(var.ssh_public_key_location)
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
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
  #user_data = file("${path.module}/entry-script.sh")
  #user_data_replace_on_change = true
}