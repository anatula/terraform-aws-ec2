terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.65.0"
    }
  }
}

#print public ip
output "ec2-public-ip" {
  value = aws_instance.myapp-server.public_ip
}