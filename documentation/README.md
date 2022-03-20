# AWS Elasticsearch Cluster EC2 

## AWS Account

To deploy the Elasticsearch ec2 cluster, you need to prepare your AWS account.

### IAM Packer user

1. Go to AWS IAM Service
2. Create a new user called `packer-aws-es-cluster`
3. Create policy named `packer-policy` and use the JSON file `aws-policy.json` in packer directory
4. Create **Access keys** of the users and configure a profile in your aws-cli terminal

### Bucket S3

For cloudformation deployment we need a S3 bbucket.

### Network configuration

- VPC
- 3 availabilities zone
- 3 Public subnets
- 3 private subnets (No Internet gateway attach to the Route Table)

### Route53 domain

We are using route53 to automatically record DNS

- HostedZone

