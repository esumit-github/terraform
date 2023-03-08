terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "AWS-EC2"
  

}

#Resource to Create Key Pair
#resource "aws_key_pair" "generated_key" {
#  key_name   = var.key_pair_name
#  public_key = var.public_key
#}
#======================================================================================
# Security Group Configuration
#======================================================================================
resource "aws_security_group" "K8Ssecuritygroup" {
  name = "K8Ssecuritygroup"
  description = "K8S-security-group  Allow HTTPS to web server"
  vpc_id      = "vpc-00a3379fece087ffb"
  
ingress {
   description = "HTTPS ingress"
   from_port   = 443
   to_port     = 443
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
ingress{
   description = "Custom TCP ingress"
   from_port   = 8080
   to_port     = 8080
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
ingress{
   description = "HTTP ingress"
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }
ingress{
   description = "SSH ingress"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
}
egress{
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
}
}
#======================================================================================
# S3 bucket Configuration
#======================================================================================
resource "aws_s3_bucket" "b" {
  bucket = "k8s.bucket.cluster1981"

  tags = {
    Name        = "k8s.bucket.cluster1981"
    Environment = "Kubernetes"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
#======================================================================================
# EC2 Instance Configuration
#======================================================================================
resource "aws_instance" "ec2_instance" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    #key_name = "${var.ami_key_pair_name}.${var.key_name}"
    count = "${var.number_of_instances}"
    #subnet_id = "${var.subnet_id}"
    key_name   = var.key_pair_name
   # public_key = var.public_key
   vpc_security_group_ids = [aws_security_group.K8Ssecuritygroup.id]
    
    

provisioner "remote-exec" {
#======================================================================================
# Connect with AWS Resoeces
#======================================================================================

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("~/Downloads/SumitAWSKeyPair.pem")}"
      host          = aws_instance.ec2_instance[0].public_ip
      timeout       = "2m"
    }

    on_failure = continue

    inline = [
      "sudo su",
      "sudo apt-get update",
      #"sudo apt-get install tomcat7 -y"
      #"curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"",
      #"logout"
    ]
  }
}
#======================================================================================
# Output
#======================================================================================
output "aws_s3_bucket" {
  value = aws_s3_bucket.b.id
}
output "ec2instance" {
  value = aws_instance.ec2_instance[0].public_ip
  #value1 = aws_instance.ec2_instance.
}
