provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "demo-server" {
    ami = "ami-09040d770ffe2224f"
    instance_type = "t2.micro"
    key_name = "sp_key_pair"
    # security_groups = [ "sp-sg" ]
    vpc_security_group_ids = [aws_security_group.sp-sg.id]
    subnet_id = aws_subnet.sp-public-subnet-01.id 

    # the below code will create three instance
    for_each = toset (["jenkins-master", "build-slave", "ansible"])
    tags = {
      Name = "${each.key}"
    }
}

resource "aws_security_group" "sp-sg" {
  name        = "sp-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.sp-vpc.id 
  
  ingress {
    description      = "Shh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Purpose = "2097411"

  }
}

resource "aws_vpc" "sp-vpc" {
  cidr_block = "20.1.0.0/16"
  tags = {
    Purpose = "2097411"
  }
  
}

resource "aws_subnet" "sp-public-subnet-01" {
  vpc_id = aws_vpc.sp-vpc.id
  cidr_block = "20.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-2a"
  tags = {
    Purpose = "2097411"
  }
}

resource "aws_subnet" "sp-public-subnet-02" {
  vpc_id = aws_vpc.sp-vpc.id
  cidr_block = "20.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-2b"
  tags = {
    Purpose = "2097411"
  }
}

resource "aws_internet_gateway" "sp-igw" {
  vpc_id = aws_vpc.sp-vpc.id 
  tags = {
    Purpose = "2097411"
  } 
}

resource "aws_route_table" "sp_public-rt" {
  vpc_id = aws_vpc.sp-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sp-igw.id 
  }
}

resource "aws_route_table_association" "sp-rta-public-subnet-01" {
  subnet_id = aws_subnet.sp-public-subnet-01.id
  route_table_id = aws_route_table.sp_public-rt.id   
}

resource "aws_route_table_association" "sp-rta-public-subnet-02" {
  subnet_id = aws_subnet.sp-public-subnet-02.id 
  route_table_id = aws_route_table.sp_public-rt.id   
}
