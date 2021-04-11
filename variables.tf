variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project. Used in resource names and tags."
  type        = string
  default     = "whispir"
}

variable "environment" {
  description = "Value of the 'Environment' tag."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Type of EC2 instance to use."
  type        = string
  default     = "t2.micro"
}

variable "instance_ami" {
  description = "AMI of EC2 instance to use (Ubuntu 20.04 by default)"
  type        = string
  default     = "ami-0d758c1134823146a"
}

variable "instances_cnt_web" {
  description = "Number of webserver nodes"
  type        = number
  default     = 2
}

variable "instances_cnt_app" {
  description = "Number of application nodes"
  type        = number
  default     = 2
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_web" {
  description = "CIDR block for web subnet"
  type        = string
  default = "10.0.1.0/24"
}

variable "subnet_cidr_app" {
  description = "CIDR block for app subnet"
  type        = string
  default = "10.0.2.0/24"
}
