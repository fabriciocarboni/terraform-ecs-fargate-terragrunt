/*
 * alb_sg.tf
 * Creates security group for Application Load Balancer
 */


resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "Security Group for load balancer"
#   vpc_id      = aws_vpc.main.id
  vpc_id      = var.vpc_id
  tags = {
    Name = "Allow access from internet"
  }

  ingress {
    description = "Allow 80 from anywhere for redirection"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

