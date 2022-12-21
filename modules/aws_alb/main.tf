/*
 * main.tf
 * Creates Application Load Balancer
 */


resource "aws_lb" "application-lb" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = "${var.public_subnets}" # it comes from modules/aws_vpc/main.tf

  tags = {
    Name = "Application Load Balancer"
  }
}

# Creating target group
resource "aws_lb_target_group" "alb-tg" {
  name        = "alb-tg"
  port        = 8081
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

# ALB Listener
resource "aws_lb_listener" "listener-http" {
  load_balancer_arn = aws_lb.application-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.id
  }
}


/*
*Variables that receives values from outputs <- modules/aws_vpc
*/
variable "vpc_id" {
  description = "VPC ID" 
  type = string
}

variable "public_subnets" {
    description = "Public subnets from VPC"
    type = list(string)
}

# Outputs
output "elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = aws_lb.application-lb.dns_name
}

output "alb_tg_arn" {
  description = "Load Balancer target group arn"
  value       = aws_lb_target_group.alb-tg.arn
}
