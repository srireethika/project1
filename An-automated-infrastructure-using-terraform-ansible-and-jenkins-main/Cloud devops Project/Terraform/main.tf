provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

resource "aws_instance" "murari_vm" {
  ami           = "ami-00a929b66ed6e0de6"
  instance_type = "t2.micro"
  key_name      = "murari-key1"  # Change if you used a different name
  security_groups = [aws_security_group.allow_ssh_http.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Murari's EC2 - Apache installed" > /var/www/html/index.html
              EOF

  tags = {
    Name = "Murari-EC2"
  }
}
resource "aws_instance" "jenkins_server" {
  ami           = "ami-00a929b66ed6e0de6"  # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"
  key_name      = "murari-key1"
  security_groups = [aws_security_group.allow_ssh_http.name]

  tags = {
    Name = "Jenkins-Server"
  }
}
