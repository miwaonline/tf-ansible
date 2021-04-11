terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "webservers" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_web
}

resource "aws_subnet" "appservers" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_app
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key" {
  key_name   = "whispir-ssh-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "SSHC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "elb_http" {
  source   = "terraform-aws-modules/elb/aws"
  name     = "elb-whispir"
  internal = false

  security_groups = [aws_security_group.allow_http.id]
  subnets         = [aws_subnet.appservers.id, aws_subnet.webservers.id]

  number_of_instances = var.instances_cnt_web + var.instances_cnt_app
  instances           = concat(aws_instance.webserver.*.id, aws_instance.appserver.*.id)

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
    }, {
    instance_port     = 443
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    }
  ]
  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }
  tags = {
    Project     = var.project_name
    Nodetype    = "elb"
    Environment = var.environment
  }
}

resource "aws_instance" "webserver" {
  count                       = var.instances_cnt_web
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.webservers.id
  vpc_security_group_ids      = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]

  tags = {
    Project     = var.project_name
    Nodetype    = "web"
    Environment = var.environment
  }
}

resource "aws_instance" "appserver" {
  count         = var.instances_cnt_app
  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id              = aws_subnet.appservers.id
  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]

  tags = {
    Terraform   = "true"
    Project     = var.project_name
    Nodetype    = "api"
    Environment = var.environment
  }
}
