terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}
# Create a VPC
  resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
# Create public subnet 
  #ap-south-1a
  #ap-south-1b
  #ap-south-1c
  
resource "aws_subnet" "sub1_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  


  tags = {
    Name = "public"
  }
}
# Create private subnet
resource "aws_subnet" "sub2_private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "private"
  }
}
#==================================================================================
# Create a public route table
resource "aws_route_table" "route_public" {
 vpc_id = aws_vpc.main.id

  route = []

  tags = {
    Name = "public"
  }
}

# Create a private route table
resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.main.id

  route = []

  tags = {
    Name = "private"
  }
}
#==================================================================================
# Create subnet association to public route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sub1_public.id
  route_table_id = aws_route_table.route_public.id
}
# Create subnet association to private route table
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sub2_private.id
  route_table_id = aws_route_table.route_private.id
}
#==================================================================================
# Create an internet gateway and attach to vpc
resource "aws_internet_gateway" "internet_Gate_way" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "internet_Gate_way"
  }
}
#==================================================================================
# Create an Elastic IP for the NAT gateway
resource "aws_eip" "net_gateway" {
  domain = "vpc"  # Use "vpc" domain to associate the EIP with the VPC

  tags = {
    Name = "EIP-NAT"
  }
}
#==================================================================================
# Create a NAT gateway and associate with the private subnet
resource "aws_nat_gateway" "net_gateway" {
  allocation_id = aws_eip.net_gateway.id
  subnet_id     = aws_subnet.sub1_public.id

  tags = {
    Name = "NAT_GW"
  }
}
#====================================================================================
# Create a route in the public route table that directs traffic to the Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.route_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_Gate_way.id
}
#====================================================================================
# Create a route in the private route table that directs traffic to the NAT Gateway
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.route_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.net_gateway.id
}
#====================================================================================
