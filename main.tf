terraform {
  required_providers {
    aws = {
      version = "6.13.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket       = "makasiw7backet"
    key          = "cicd/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = false
  }
}


resource "aws_instance" "cicd" {
  ami           = "ami-08982f1c5bf93d976"
  instance_type = "t3.micro"
  region        = "us-east-1"

  user_data = <<-EOF
    #!/bin/bash
    set -e

    echo "[INFO] Updating system..."
    yum update -y

    echo "[INFO] Installing Docker..."
    yum install docker -y
    usermod -aG docker ec2-user
    systemctl start docker
    systemctl enable docker

    echo "[INFO] Customizing terminal prompt..."
    echo "PS1='\\e[1;32m\\u@\\h \\w$ \\e[m'" >> /home/ec2-user/.bash_profile

    echo "[INFO] Installing Git and wget..."
    yum install git -y
    yum install wget -y

    echo "[INFO] Installing Docker Compose..."
   latest_version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | cut -d '"' -f 4 || echo "v2.24.1")
curl -L "https://github.com/docker/compose/releases/download/$${latest_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose


    chmod +x /usr/local/bin/docker-compose

    echo "[INFO] Docker Compose version:"
    docker-compose --version
  EOF
  tags = {
    Name = "Dev-CICD"
  }
}
