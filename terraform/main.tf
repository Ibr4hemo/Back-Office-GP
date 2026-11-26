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

resource "aws_subnet" "Public-Subnet" {
  vpc_id     = aws_vpc.Traffic-managment-system.id
  cidr_block = "100.1.1.0/24"
  map_public_ip_on_launch=false
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_subnet" "Private-Subnet" {
  vpc_id     = aws_vpc.Traffic-managment-system.id
  cidr_block = "100.1.2.0/24"
  map_public_ip_on_launch=true
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_internet_gateway" "Traffic-managment-IGW" {
  vpc_id = aws_vpc.Traffic-managment-system.id

  tags = {
    Name = "Traffic-managment-IGW"
  }
}

resource "aws_route_table" "Public Routes" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Traffic-managment-IGW.id
  }

  tags = {
    Name = "Public Routes"
  }
}
