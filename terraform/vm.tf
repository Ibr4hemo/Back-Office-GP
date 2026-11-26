resource "aws_instance" "Kubernetes" {
  ami           = "ami-083dedce92603a2ad"
  instance_type = "t3.micro"

  tags = {
    Name = "Kubernetes"
  }
}
