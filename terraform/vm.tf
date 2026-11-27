resource "aws_security_group" "k8s_sg" {
  name        = "traffic-k8s-ec2-sg"
  vpc_id      = aws_vpc.Traffic-managment-system.id

  ingress {
    description = "Cluster internal traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["156.214.245.245/32"]
  }

  ingress {
    description = "HTTP ingress for CloudFront and browser traffic"
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

resource "aws_key_pair" "k8s_key" {
  key_name   = "traffic-managment"
  public_key = file("~/.ssh/traffic-managment.pub")
}

resource "random_password" "k8s_token" {
  length  = 32
  special = false
}

resource "aws_instance" "k8s_master" {
  ami           = "ami-05253e540604dbbae"
  instance_type = "t3.small"
  subnet_id = aws_subnet.Private-Subnet.id
  key_name = aws_key_pair.k8s_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  depends_on = [aws_instance.nat_instance]

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

user_data = <<-EOF
    #!/bin/bash
    set -e
    hostnamectl set-hostname k3s-master

    # Add 1GB swap as safety buffer
    fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab

    # Install K3s Server (Control Plane)
    curl -sfL https://get.k3s.io | K3S_TOKEN="${random_password.k8s_token.result}" sh -s - server \
      --write-kubeconfig-mode 644 \
      --node-name k8s-master

    # Allow ubuntu user to run kubectl without sudo
    mkdir -p /home/ubuntu/.kube
    cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
  EOF

  tags = {
    Name = "k8s_master"
  }
}

resource "aws_instance" "k8s_worker" {
  ami           = "ami-05253e540604dbbae"
  instance_type = "t3.small"
  subnet_id = aws_subnet.Public-Subnet.id
  key_name = aws_key_pair.k8s_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  depends_on = [aws_instance.k8s_master]

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

user_data = <<-EOF
    #!/bin/bash
    set -e
    hostnamectl set-hostname k3s-worker

    # Add 1GB swap for Python container image pulls
    fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab

    # Wait until K3s Master API (port 6443) is ready
    until curl -k -s https://${aws_instance.k8s_master.private_ip}:6443/ping >/dev/null 2>&1; do
      sleep 5
    done

    # Install K3s Agent (Worker) and auto-join Master
    curl -sfL https://get.k3s.io | K3S_URL="https://${aws_instance.k8s_master.private_ip}:6443" \
      K3S_TOKEN="${random_password.k8s_token.result}" sh -s - agent \
      --node-name k8s-worker
  EOF

  tags = {
    Name = "k8s_worker"
  }
}

resource "aws_instance" "admin" {
  ami           = "ami-05253e540604dbbae"
  instance_type = "t3.small"
  subnet_id = aws_subnet.Public-Subnet.id
  key_name = aws_key_pair.k8s_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

user_data = <<-EOF
    #!/bin/bash
    set -e
    hostnamectl set-hostname admin
  EOF

  tags = {
    Name = "admin"
  }
}
