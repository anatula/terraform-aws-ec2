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

- create Route Table and Internet Gateway
- provision EC2 instance
- deploy nginx docker container
- create security group (firewall)
