terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}
# Configure aws provider
provider "aws" {
  region     = "us-east-1"
  #access_key = ""
  #secret_key = ""
}
# Create vpc
resource "aws_vpc" "udemylab-vpc" {
  cidr_block = var.cidr_bloc[0]
  tags = {
    Name = "udemylab-vpc"
  }
}
# Create Subnet
resource "aws_subnet" "udemylab-subnet1" {
  vpc_id = aws_vpc.udemylab-vpc.id
  cidr_block = var.cidr_bloc[1]
  tags = {
    Name ="udemylab-subnet1"
  }
}
#  Create Internet Gateway
resource "aws_internet_gateway" "udemylab-internetgateway" {
  vpc_id = aws_vpc.udemylab-vpc.id
  tags = {
    Name = "udemylab-internetgateway"
  }
}
#  Security group resource
resource "aws_security_group" "udemylab-securityGroup" {
  vpc_id = aws_vpc.udemylab-vpc.id

  tags = {
    Name = "udemylab-securityGroup"
  }
  description = "to allow inbound and outbound traffic to my udemylab "
  dynamic ingress  {
    iterator = port
    for_each = var.ports
    content {
      from_port = port.value
      protocol  = "tcp"
      to_port   = port.value
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}
#  Create route table and association

resource "aws_route_table" "udemylab-routeTable" {
  vpc_id = aws_vpc.udemylab-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.udemylab-internetgateway.id
  }
  tags = {
    Name = "udemylab-routeTable"
  }
}
resource "aws_route_table_association" "udemylab-routetableassociation" {
  #vpc_id = aws_vpc.udemylab-vpc.id
  subnet_id = aws_subnet.udemylab-subnet1.id
  route_table_id = aws_route_table.udemylab-routeTable.id
}

#  Create aws  EC2

resource "aws_instance" "jenkens" {
  ami           = var.instance.ami
  instance_type = var.instance.type
  key_name = var.instance.key_name
  vpc_security_group_ids = [aws_security_group.udemylab-securityGroup.id]
  subnet_id = aws_subnet.udemylab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallJenkins.sh")
  tags = {
    Name = "jenkens-service"
  }
}

# Create an AWS EC2 Instance to host Ansible Controller (Control node)

resource "aws_instance" "AnsibleController" {
  ami           = var.instance.ami
  instance_type = var.instance.type
  key_name = var.instance.key_name
  vpc_security_group_ids = [aws_security_group.udemylab-securityGroup.id]
  subnet_id = aws_subnet.udemylab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallAnsibleCN.sh")

  tags = {
    Name = "Ansible-ControlNode"
  }
}
# Create/Launch an AWS EC2 Instance(Ansible Managed Node1) to host Apache Tomcat server
resource "aws_instance" "AnsibleManagedNode1" {
  ami           = var.instance.ami
  instance_type = var.instance.type
  key_name = var.instance.key_name
  vpc_security_group_ids = [aws_security_group.udemylab-securityGroup.id]
  subnet_id = aws_subnet.udemylab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./AnsibleManagedNode.sh")

  tags = {
    Name = "AnsibleManagedN-ApacheTomcat"
  }
}

# Create/Launch an AWS EC2 Instance(Ansible Managed Node2) to host Docker
resource "aws_instance" "AnsibleManagedDockerHost" {
  ami                         = var.instance.ami
  instance_type               = var.instance.type
  key_name                    = var.instance.key_name
  vpc_security_group_ids      = [aws_security_group.udemylab-securityGroup.id]
  subnet_id                   = aws_subnet.udemylab-subnet1.id
  associate_public_ip_address = true
  user_data                   = file("./Docker.sh")

  tags = {
    Name = "AnsibleManagedN-Docker"
  }
}

# Create/Launch an AWS EC2 Instance to host Sonatype Nexus
resource "aws_instance" "nexus" {
  ami                         = var.instance.ami
  instance_type               = "t2.medium"
  key_name                    = var.instance.key_name
  vpc_security_group_ids      = [aws_security_group.udemylab-securityGroup.id]
  subnet_id                   = aws_subnet.udemylab-subnet1.id
  associate_public_ip_address = true
  user_data                   = file("./InstallNexus.sh")

  tags = {
    Name = "Nexus-Server"
  }
}
# CMD Memento
  # 1 .terraform init => initialize the backend
  # 2 .terraform refresh => display state
  # 3 .terraform plan => Generate  execution plan
  # 3 .terraform apply => will create resources on aws
# Check
  # 5. terraform refresh
    # Ouput example : aws_vpc.udemylab-vpc: Refreshing state... [id=vpc-07a4da44f34e0dc3b]
# Destroy
  # 6. terraform destroy => Remove resource on aws and reset state. You should do init,plan ,apply again
# After file Updated do
  # 1. terraform plan
  # 1. terraform apply or terraform apply -- auto-approve
# Prepare ansible playbook beetween Controller and Manager
# On Controller do ssh-keygen
# cd cd /home/ansibleadmin/.ssh
# ssh-copy-id @IP-Manager
# ssh @IP-Manager