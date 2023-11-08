terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# VPC Creation
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "project VPC"
  }
}

# Public Subnet
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-subnet"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat-eip" {
}

# Private Subnet
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "test-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# NAT Gateway
resource "aws_nat_gateway" "my-ngw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet.id

  depends_on = [aws_internet_gateway.test-igw] # Make sure the internet gateway is created first
}

# Private Route Table
resource "aws_route_table" "pri-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-ngw.id
  }

  tags = {
    Name = "pri-rt"
  }
}

# Route Table Association for Private Subnet
resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.pri-rt.id
}

# Security Group
resource "aws_security_group" "test_access" {
  name        = "test_access"
  description = "allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

# Key Pair
resource "aws_key_pair" "mumbaikey3" {
  key_name   = "mumbaikey3"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvBynpqrremQuE0lokuFgMn0GAVI7VUxALey1HrLvxtfJOE1236GJTq2ECgbr6JnVMN7g9z66RHYqIUu/WU55bXeova/RYIYgWaaaGF603HORG6tLbnF74DBwa35/sK1sCh19dNEk9Wd/WCOAwJA6/mvj2l0jRt3Zg4OYh6ovEVfJag6cn4pfrTrEHSM8ytcYCAuBz/ZfGCAtPZC7oN3/qTELmArb3UZc4jdZqhcFdjOld4RgYBJzaRwYmMoRsC2cYsJK4mS4zSR4LkTxdiKCNAMzD09d1AlLR9a7snF32GfnntYcYQn7t1LXC+/JGhQwfjzpmfoXRu8HNQZ4GzSS+sdR8cQYIPjIYpippx06sX/XkKT/NbJhtxBdGyAOD4rpt11W1ZAa8i+vxkjAfB4R8d+flTKK/p/NG1FBXeQ/vUYVXviIScEYoeQ3bnNhIqqhyQe31juiOlEMdPbhyN1IujOn6y3zlE9C3DU9fwGqLbV8dBYrcPuPzO6BcHTMgGtE= root@ip-172-31-34-238.ap-south-1.compute.internal"
}

# EC2 Instance - Sanjay Server
resource "aws_instance" "sanjay-server" {
  ami                    = "ami-05c13eab67c5d8861"
  subnet_id              = aws_subnet.public-subnet.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.test_access.id]
  key_name               = aws_key_pair.mumbaikey3.key_name # Use the key pair resource
  tags = {
    Name     = "test-World"
    Stage    = "testing"
    Location = "chennai"
  }
}

# EIP for EC2 Instance
resource "aws_eip" "sanjay-ec2-eip" {
  instance = aws_instance.sanjay-server.id
}

# EC2 Instance - Gautam Server
resource "aws_instance" "gautam-server" {
  ami                    = "ami-05c13eab67c5d8861"
  subnet_id              = aws_subnet.private-subnet.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.test_access.id]
  key_name               = aws_key_pair.mumbaikey3.key_name # Use the key pair resource
  tags = {
    Name     = "gautam-World"
    Stage    = "stage-base"
    Location = "delhi"
  }
}
