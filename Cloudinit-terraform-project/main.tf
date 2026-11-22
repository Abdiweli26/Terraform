terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.72.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "wordpress_vpc"
  }

}


resource "aws_subnet" "public" {
  vpc_id     = aws_default_vpc.default.id
  cidr_block = var.cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone = var.availability_zone


  tags = {
    Name = "var.subnet_name"
  }
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  user_data = templatefile("${path.module}/cloudinit.yml", {
   
  })

  tags = {
    Name = "Wordpress_Instance"
  }
}
resource "aws_iam_role" "test_role" {
  name = var.iam_role_name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "wordpress_iam_role"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}



resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "test_sg" {

  # ... other configuration ...
  name = var.security_group_name
  vpc_id = aws_default_vpc.default.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
}
 
}