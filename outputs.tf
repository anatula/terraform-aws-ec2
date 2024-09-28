output "aws_ami_id" {
    value = module.myapp-server.aws_ami_id
}

output "ec2-public-ip" {
    value = module.myapp-server.ec2_public_ip
}