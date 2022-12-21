# AWS automation - ECS Fargate Cluster using Terragrunt

## Files organization
![](![](https://github.com/fabriciocarboni/cncf-kcna-exam-topics/blob/main/assets/Diagrams-Terragrunt.png))

## Diagram stack
![](![](https://github.com/fabriciocarboni/cncf-kcna-exam-topics/blob/main/assets/ecs-diagram.jpg))

## Requirements:

Clone this repo:
```
git clone https://github.com/fabriciocarboni//
terraform-ecs-fargate-terragrunt
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

## Deploy (layer by layer)

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

