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
  region = "ap-south-1"
}
resource "aws_security_group" "web_access" {
  name        = "web_access"
  description = "allow ssh and http"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_key_pair" "mumbaikey2" {
  key_name   = "mumbaikey2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvBynpqrremQuE0lokuFgMn0GAVI7VUxALey1HrLvxtfJOE1236GJTq2ECgbr6JnVMN7g9z66RHYqIUu/WU55bXeova/RYIYgWaaaGF603HORG6tLbnF74DBwa35/sK1sCh19dNEk9Wd/WCOAwJA6/mvj2l0jRt3Zg4OYh6ovEVfJag6cn4pfrTrEHSM8ytcYCAuBz/ZfGCAtPZC7oN3/qTELmArb3UZc4jdZqhcFdjOld4RgYBJzaRwYmMoRsC2cYsJK4mS4zSR4LkTxdiKCNAMzD09d1AlLR9a7snF32GfnntYcYQn7t1LXC+/JGhQwfjzpmfoXRu8HNQZ4GzSS+sdR8cQYIPjIYpippx06sX/XkKT/NbJhtxBdGyAOD4rpt11W1ZAa8i+vxkjAfB4R8d+flTKK/p/NG1FBXeQ/vUYVXviIScEYoeQ3bnNhIqqhyQe31juiOlEMdPbhyN1IujOn6y3zlE9C3DU9fwGqLbV8dBYrcPuPzO6BcHTMgGtE= root@ip-172-31-34-238.ap-south-1.compute.internal"
}

resource "aws_instance" "app_server" {
  ami               = "ami-0287a05f0ef0e9d9a"
  availability_zone = "ap-south-1a"
  instance_type     = "t2.micro"
  security_groups   = ["${aws_security_group.web_access.name}"]
  key_name          = aws_key_pair.mumbaikey2.key_name

  tags = {
    Name = "Developer"
  }
}
