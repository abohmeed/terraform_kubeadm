provider "aws" {
  region  = "eu-west-2"
}
terraform {
   backend "s3" {
    bucket = "skyvalley-terraform-state"
    key    = "default.tfstate"
    region = "eu-west-1"
  }
}
module "kubernetes" {
  source = "./kubernetes"
  ami = "ami-00da2ce1db1f11a7d"
  cluster_name = "basic-cluster"
  master_instance_type = "t3.medium"
  nodes_max_size = 1
  nodes_min_size = 1
  private_subnet01_netnum = "1"
  public_subnet01_netnum = "2"
  region = "eu-west-2"
  vpc_cidr_block = "10.240.0.0/16"
  worker_instance_type = "t3.medium"
  vpc_name = "kubernetes"
}
