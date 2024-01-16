Terraform code:
    terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA3GT6ROYWQWWHPU2R"
  secret_key = "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"
}

# Task 1: Create VPC with public and private subnets
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet_1"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "PrivateSubnet"
  }
}

# Task 6: Create Elastic IP for NAT Gateway
resource "aws_eip" "my_nat_gateway_eip" {
  
}

# Task 7: Create NAT Gateway and associate with Elastic IP
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "MyNATGateway"
  }
}

# Task 2: Launch EC2 instance in private subnet with Apache installation and Security Group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
   
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-023c11a32b0207432" 
  instance_type = "t2.micro"
  key_name      = "demotaskkey"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids  = [aws_security_group.my_security_group.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              service httpd start
              chkconfig httpd on
              EOF

  tags = {
    Name = "MyEC2Instance"
  }
}

# Task 3: Create Internet Gateway
resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

# Task 4: Create Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.my_internet_gateway.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Task 5: Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Task 8: Create a private route table for NAT Gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

# Task 9: Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Task 10: Create Load Balancer in the public subnet
resource "aws_lb" "my_load_balancer" {
  name               = "MyLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_security_group.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_1.id]

  enable_deletion_protection         = false
  enable_cross_zone_load_balancing   = true
  enable_http2                       = true
  idle_timeout                       = 400
}

# Task 11: Add EC2 instance to the Load Balancer
resource "aws_lb_target_group" "my_target_group" {
  name     = "MyTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "my_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_ec2_instance.id
}
