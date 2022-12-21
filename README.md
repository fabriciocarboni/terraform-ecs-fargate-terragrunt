# AWS automation - ECS Fargate Cluster using Terragrunt

## Files organization
![](https://github.com/fabriciocarboni/terraform-ecs-fargate-terragrunt/blob/main/assets/Diagrams-Terragrunt.png)

## Diagram stack
![](https://github.com/fabriciocarboni/terraform-ecs-fargate-terragrunt/blob/main/assets/ecs-diagram.jpg)
## Requirements:

Clone this repo:
```
git clone https://github.com/fabriciocarboni/terraform-ecs-fargate-terragrunt
cd terraform-ecs-fargate-terragrunt
```

Terraform version 1.3.2 [https://releases.hashicorp.com/terraform/1.3.2/]( https://releases.hashicorp.com/terraform/1.3.2/ )
 
```
  wget https://releases.hashicorp.com/terraform/1.3.2/terraform_1.3.2_linux_amd64.zip
  unzip terraform_1.3.2_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  rm -fr terraform_1.3.2_linux_amd64.zip
```
Terragrunt version 0.39.1 [https://github.com/gruntwork-io/terragrunt/releases/tag/v0.39.1](https://github.com/gruntwork-io/terragrunt/releases/tag/v0.39.1)
 
```
  wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.39.1/terragrunt_linux_amd64
  sudo mv terragrunt_linux_amd64 terragrunt
  sudo mv terragrunt /usr/local/bin/
  sudo chmod u+x /usr/local/bin/terragrunt
```
AWS CLI [(https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

## Credentials
In order to start this:

Copy your aws credentials in your terminal so AWSCLI can have access on it as environment variables. Place the credentials within the commas.
```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION=us-east-1
```
Create in the github repository the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in order to the github actions be able to push the app image to ECR. Settings -> Secrets -> Actions -> New Repository Secret.

# Steps

## Create network with 2 publics & 2 privates subnet (vpc.tf) (2 differents AZs)
- 2 publics subnets: To acomodate our application load balancer
- 2 private subnets: To acomodate our fargate tasks
- 1 Internet Gateway along with route table
- 2 NAT Gateways along with its route tables and subnets association.

## Create security groups
- 1 security group has been created for our load balancer (security_groups.tf)
- 1 security group has been created for our ecs service. This security group allows our fargate tasks pull image from ecr and allow inbound requests from load balancer security group. (ecs_fargate.tf)

## Create a load balancer (ALB) (elb.tf)
The Application Load Balancer that is responsible to balance requests among two tasks

## Create Elastic Container Registry(ECR) repository (ecr.tf)
A repository has been created in order to accommodate our app image. As soon as a push is made on our branch in github, it will push to our repository in aws. (.github/workflows/deploy.yaml)

## Create a Fargate cluster (ecs_fargate.tf)
1. Fargate cluster
2. A task definition
3. A service has been created. It's responsible to guarantee that we will always have our minimum tasks running at all times

## Deploy 
### (layer by layer)

This way we are going to deploy layer by layer.

1) Initialize Terragrunt
```
cd terraform-ecs-fargate-terragrunt/staging
terragrunt init
```
2) Deploy Networking (VPC)
* VPC infra need to be applied first because other modules depends on it. Only after VPC is applied the other modules will benefit from VPC outputs and be used as inputs in them.
```
cd aws_vpc
terragrunt validate
terragrunt plan
terragrunt apply
```

4) Deploy Application Load Balancer (ALB)
```
cd ../aws_alb
terragrunt validate
terragrunt plan
terragrunt apply
```

4) Deploy Elastic Container Registry (ECR)
```
cd ../aws_ecr
terragrunt validate
terragrunt plan
terragrunt apply
```

4) Deploy Elastic Container Service - Fargate (ECS)
```
cd ../aws_ecs
terragrunt validate
terragrunt plan
terragrunt apply
```

## Deploy the environment as a whole
```
cd staging
terragrunt validate
terragrunt run-all apply --terragrunt-non-interactive
```
We use `--terragrunt-non-interactive` because terraform will ask if it can create the backend in s3 in order to store the states files.

