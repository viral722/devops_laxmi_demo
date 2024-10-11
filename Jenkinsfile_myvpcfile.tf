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
 access_key = "AKIAYK5VJLLJ2PVJJY6X"
  secret_key = "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"
}
# Create a VPC
  resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
