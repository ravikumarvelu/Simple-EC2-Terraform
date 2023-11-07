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

resource "aws_instance" "app_server" {
  ami               = "ami-0287a05f0ef0e9d9a"
  availability_zone = "ap-south-1a"
  instance_type     = "t2.micro"

  tags = {
    Name = "Developer"
  }
}
