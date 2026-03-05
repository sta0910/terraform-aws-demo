#-----------------
# Terraform configuration
#-----------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
  backend "s3" {
    bucket  = "tastylog-tfstate-bucket-sota-takahashi" #本来はアカウントを分けるべきだか今回は同一アカウントで
    key     = "tastylog-dev-tfstate"                   #devの部分を変数化するとうまく動かない
    region  = "ap-northeast-1"
    profile = "terraform"
  }
}

#-----------------
#Provider
#-----------------
provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
}

#-----------------
#Variables
#-----------------

variable "project" {
  type = string
}

variable "enviroment" {
  type = string
}