resource "aws_key_pair" "kind_host" {
  key_name   = "traffic-managment"
  public_key = file("~/.ssh/traffic-managment.pub")
}

resource "aws_instance" "kind_host" {
  ami           = "ami-05253e540604dbbae"
  instance_type = "t3.small"
  subnet_id = aws_subnet.Private-Subnet.id
  key_name = aws_key_pair.Kubernetes.key_name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # 1. Add 2GB Swap to protect against OOM
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab

    # 2. Install Docker
    apt-get update -y
    apt-get install -y docker.io curl git
    systemctl enable --now docker
    usermod -aG docker ubuntu

    # 3. Install kubectl & kind (amd64)
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl

    curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
    chmod +x /usr/local/bin/kind

    # 4. Create kind cluster config with Port 80 mapped
    cat <<EOT > /home/ubuntu/kind-config.yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
      extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
    EOT

    chown ubuntu:ubuntu /home/ubuntu/kind-config.yaml

    # 5. Spin up kind cluster and NGINX Ingress Controller as ubuntu user
    su - ubuntu -c "kind create cluster --config /home/ubuntu/kind-config.yaml --name traffic-cluster"
    su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
  EOF

  tags = {
    Name = "kind_host"
  }
}
