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
  map_public_ip_on_launch=true

  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_subnet" "Private-Subnet" {
  vpc_id     = aws_vpc.Traffic-managment-system.id
  cidr_block = "100.1.2.0/24"
  map_public_ip_on_launch=false
  
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

resource "aws_security_group" "nat_sg" {
  name   = "traffic-nat-sg"
  vpc_id = aws_vpc.Traffic-managment-system.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.Private-Subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat_instance" {
  ami                    = "ami-05253e540604dbbae"
  instance_type          = "t3.micro" 
  subnet_id              = aws_subnet.Public-Subnet.id
  vpc_security_group_ids = [aws_security_group.nat_sg.id]
  source_dest_check      = false

  user_data = <<-EOF
    #!/bin/bash
    sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    IFACE=$(ip route | grep default | awk '{print $5}')
    iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE
    apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
  EOF

  tags = { Name = "traffic-nat-instance" }
}

resource "aws_route_table" "Public-Routes" {
  vpc_id = aws_vpc.Traffic-managment-system.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Traffic-managment-IGW.id
  }

  tags = {
    Name = "Public-Routes"
  }
}

resource "aws_route_table_association" "Public-Routes-association" {
  subnet_id      = aws_subnet.Public-Subnet.id
  route_table_id = aws_route_table.Public-Routes.id
}

resource "aws_route_table" "Private-Routes" {
  vpc_id = aws_vpc.Traffic-managment-system.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  }

  tags = {
    Name = "Private-Routes"
  }
}

resource "aws_route_table_association" "Private-Routes-association" {
  subnet_id      = aws_subnet.Private-Subnet.id
  route_table_id = aws_route_table.Private-Routes.id
}
