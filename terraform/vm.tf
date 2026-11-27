resource "aws_security_group" "k8s_sg" {
  name        = "traffic-k8s-ec2-sg"
  description = "Allow SSH and HTTP traffic to kind cluster"
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

locals {
  k8s_base_setup = <<-EOT
    # Disable swap (Required by kubelet)
    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    # Load kernel modules & sysctl settings
    cat <<EOF | tee /etc/modules-load.d/k8s.conf
    overlay
    br_netfilter
    EOF
    modprobe overlay
    modprobe br_netfilter

    cat <<EOF | tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward                 = 1
    EOF
    sysctl --system

    # Install containerd
    apt-get update -y
    apt-get install -y apt-transport-https ca-certificates curl gpg containerd
    mkdir -p /etc/containerd
    containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' > /etc/containerd/config.toml
    systemctl restart containerd
    systemctl enable containerd

    # Install kubeadm, kubelet, kubectl (v1.31)
    mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
    apt-get update -y
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl
    systemctl enable --now kubelet
  EOT
}

resource "aws_key_pair" "k8s_key" {
  key_name   = "traffic-managment"
  public_key = file("~/.ssh/traffic-managment.pub")
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
    hostnamectl set-hostname k8s-master
    ${local.k8s_base_setup}

    # Initialize Kubernetes Control Plane
    kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Mem

    # Configure kubectl for ubuntu user
    mkdir -p /home/ubuntu/.kube
    cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
    chown -R ubuntu:ubuntu /home/ubuntu/.kube

    # Install Flannel CNI Pod Network
    su - ubuntu -c "kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"

    # Install NGINX Ingress Controller configured to bind directly to Worker Port 80
    su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml"
    sleep 15
    su - ubuntu -c "kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' -p='[{\"op\": \"add\", \"path\": \"/spec/template/spec/hostNetwork\", \"value\": true}]'"

    # Save the worker join command to a file for easy retrieval
    kubeadm token create --print-join-command > /home/ubuntu/join-command.sh
    chmod +x /home/ubuntu/join-command.sh
    chown ubuntu:ubuntu /home/ubuntu/join-command.sh
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

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    hostnamectl set-hostname k8s-worker
    ${local.k8s_base_setup}
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

  tags = {
    Name = "admin"
  }
}
