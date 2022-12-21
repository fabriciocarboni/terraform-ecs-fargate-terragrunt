/*
 * main.tf
 * Creates a Amazon Elastic Container Service - Fargate
 */


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  aws_account_id  = data.aws_caller_identity.current.account_id
  aws_region      = data.aws_region.current.name
  repository_name = "demo-nginx-app"
  task_image      = "${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/${local.repository_name}:latest"
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "role-name"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ecs-tasks.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }
]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "role-name-task"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ecs-tasks.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_cluster" "app" {
  name = "fargate-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_task_definition" "app-task-definition" {
  family                   = "app-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"  # = 0.5 vCPU https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  memory                   = "1024" # mb
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "${local.task_image}"
      cpu       = 512
      memory    = 1024 #mb
      essential = true
      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_security_group" "fargate-service-sg" {
  name        = "fargate-svc-sg"
  description = "Security Group for Fargate Service"
#   vpc_id      = aws_vpc.main.id
  vpc_id      = var.vpc_id
  tags = {
    Name = "Allow access from main load balancer to fargate service"
  }

  ingress {
    description = "Allow request from load balancer security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "app" {
  name                               = "nginx-service"
  cluster                            = aws_ecs_cluster.app.id
  launch_type                        = "FARGATE"
  task_definition                    = aws_ecs_task_definition.app-task-definition.arn
  desired_count                      = 2
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 30

  network_configuration {
    security_groups  = [aws_security_group.fargate-service-sg.id]
    # subnets          = [aws_subnet.private-a.id, aws_subnet.private-b.id]
    subnets          = "${var.private_subnets}"
    assign_public_ip = true
  }

  load_balancer {
    # target_group_arn = aws_lb_target_group.alb-tg.arn
    target_group_arn = var.alb_tg_arn
    container_name   = "nginx"
    container_port   = 8081
  }
}

/*
*Variables that receives values from outputs
*/
variable "vpc_id" {
  description = "VPC ID" 
  type = string
}

variable "alb_tg_arn" {
    description = "Load Balancer target group arn"
    type = string
}

variable "private_subnets" {
    description = "Private subnets"
    type = list(string)
}