provider "aws" {
  region  = "eu-west-2"
}
terraform {
   backend "s3" {
    bucket = "# Add your S3 bucket here"
    key    = "default.tfstate"
    region = "# Add the S3 bucket region"
  }
}
module "kubernetes" {
  source = "./kubernetes"
  ami = "# Your configured AMI"
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
  ssh_public_key = "# Add your public SSH key"
}
