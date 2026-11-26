provider "aws" {
    region = "eu-north-1"
}

resource "aws_vpc" "Traffic-managment-system" {
  cidr_block       = "100.1.0.0/20"
  instance_tenancy = "default"

  tags = {
    Name = "Traffic-managment-system"
  }
}
