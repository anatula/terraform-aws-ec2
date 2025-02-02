This code uses terraform tp provide an AWS ec2 instance that will launch an an nginx server.
This code creates a VPC, uses modules to create a subnet and a webserver.
To launch it, the ec2's instance has thr `user_data` field with a script that will gets executed when the ec2 is instanciated.

Steps to run:

1. Install AWS CLI and set env vars AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
2. Create key pair to access the ec2 with ssh, for example:
   In local machine: `ssh-keygen -t ed25519 -f ~/.ssh/aws_ec2_terraform -C "for aws ec2 terraform"`
3. Check terraform installation ([install terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))
   ```
   >terraform version
   Terraform v1.9.6
   on darwin_amd64
   ```
4. Create a `terraform.tfvars` with (for example):

```
vpc_cidr_block = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
avail_zone = "eu-central-1b"
env_prefix = "dev"
sg_ip_ingress_cidr_block="91.170.196.211/32"
instance_type="t2.micro"
ssh_public_key_location="~/.ssh/aws_ec2_terraform.pub"
image_name = "al2023-ami-*-x86_64"
```

5. Do `terraform init`
6. Do `terraform apply`
7. Copy the output of `ec2-public-ip` add port `8080` and you should see the nginx welcome page in your browser.
8. To delete all the resources `terraform destroy`

The "generic" steps terraform will perform:

9. create custom VPC
10. create custom Subnet
11. create Route Table and Internet Gateway

We have the VPC & subnet inside. Now, we're connecting VPC to Internet Gateway and we're configuring a new Route Table that we are creating in the VPC to route all the traffic to and from Internet using an Internet Gateway.

RouteTable = virtual router
Internet Gateway = virtual modem connecting to internet

4. Create an explicit subnet association with our Route Table

All the resources that will be deployed into our subnet, EC2, etc all this requests will be handled by this route table (we will be able to ssh into the EC2 instance, access nginx server through the browser)

5. Use the default main route table created by AWS
6. Configure firewall rules for our EC2 instance: security group

- open port 22 (ssh)
- open port 8080 (nginx access from browser)

1.  Use default security group
2.  Provision EC2 instance
3.  Deploy nginx docker container
4.  Check, using the public IP of the ec2 instance on port 8080, should see the nginx welcome screen

Note:
A `user_data` change will force the recreation of the instance with `user_data_replace_on_change = true`
Modify the `entry-script.sh` file for `user_data` to read from.
To ssh note the public ip to connect: `ssh -i ~/.ssh/PRIVATE_KEY ec2-user@PUBLIC_IP`
Remember that on recreation the public ip will also change.
