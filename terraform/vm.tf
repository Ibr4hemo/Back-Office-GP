resource "aws_key_pair" "kind_host" {
  key_name   = "traffic-managment"
  public_key = file("~/.ssh/traffic-managment.pub")
}

resource "aws_instance" "kind_host" {
  ami           = "ami-05253e540604dbbae"
  instance_type = "t3.small"

  tags = {
    Name = "kind_host"
  }
}
