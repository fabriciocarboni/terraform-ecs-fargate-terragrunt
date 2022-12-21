/*
 * main.tf
 * Creates VPC and its related services
 */


# Main VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/21"

  tags = {
    Name = "Main VPC"
  }
}

# Public Subnets
resource "aws_subnet" "public-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-a"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-b"
  }
}

# Private Subnets
resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-a"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-b"
  }
}

# Main Internet Gateway for VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main IGW"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "public-assoc-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_route_table_association" "public-assoc-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public-rt.id
}


# Route Table for Private Subnet via nat-gw-a
resource "aws_route_table" "private-rt-a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw-a.id
  }

  tags = {
    Name = "Private Route Table-a"
  }
}

# Route Table for Private Subnet via nat-gw-b
resource "aws_route_table" "private-rt-b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw-b.id
  }

  tags = {
    Name = "Private Route Table-b"
  }
}

# Association between Private Subnet and Private Route Table
resource "aws_route_table_association" "private-assoc-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private-rt-a.id
}

resource "aws_route_table_association" "private-assoc-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private-rt-b.id
}

# Elastic IP for NAT Gateway public-a
resource "aws_eip" "nat_eip-a" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "NAT Gateway EIP public-1"
  }
}

# NAT Gateway for public-a
resource "aws_nat_gateway" "nat-gw-a" {
  allocation_id = aws_eip.nat_eip-a.id
  subnet_id     = aws_subnet.public-a.id

  tags = {
    Name = "NAT Gateway Public-a"
  }
}

# Elastic IP for NAT Gateway public-b
resource "aws_eip" "nat_eip-b" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "NAT Gateway EIP public-b"
  }
}

# NAT Gateway for public-b
resource "aws_nat_gateway" "nat-gw-b" {
  allocation_id = aws_eip.nat_eip-b.id
  subnet_id     = aws_subnet.public-b.id

  tags = {
    Name = "NAT Gateway Public-b"
  }
}

/*
* Outputs that will be passed to aws_alb module
* and be inputed in inputs block in aws_alb/terragrunt.hcl
*/

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnets"{
  description = "Public subnets"
  value = [aws_subnet.public-a.id,aws_subnet.public-b.id]
}

output "private_subnets"{
  description = "Private subnets"
  value = [aws_subnet.private-a.id,aws_subnet.private-b.id]
}

