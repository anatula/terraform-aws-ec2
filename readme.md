1. Set env vars AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
2. create custom VPC
3. create custom Subnet

Create a `terraform.tfvars` with:

```
vpc_cidr_block = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
avail_zone = "eu-central-1b"
env_prefix = "dev"
```

4. create Route Table and Internet Gateway

We have the VPC & subnet inside. Now, we're connecting VPC to Internet Gateway and we're configuring a new Route Table that we are creating in the VPC to route all the traffic to and from Internet using an Internet Gateway.

RouteTable = virtual router
Internet Gateway = virtual modem connecting to internet

5. create an explicit subnet association with our Route Table

All the resources that will be deployed into our subnet, EC2, etc all this requests will be handled by this route table (we will be able to ssh into the EC2 instance, access nginx server through the browser)

- provision EC2 instance
- deploy nginx docker container
- create security group (firewall)
