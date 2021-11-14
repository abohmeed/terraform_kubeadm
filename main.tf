provider "aws" {
  region  = "eu-west-2"
}
terraform {
   backend "s3" {
<<<<<<< HEAD
    bucket = # Add your S3 bucket here
=======
    bucket = # Your bucket
>>>>>>> e914bf3781c8444250ed99fa80aded092e6cafc6
    key    = "default.tfstate"
    region = # Add the S3 bucket region
  }
}
module "kubernetes" {
  source = "./kubernetes"
<<<<<<< HEAD
  ami = "ami-0d47c6174ad79eb43"
  cluster_name = "basic-cluster"
=======
  ami = # Your configured AMI
  cluster_name = # Your cluster name
>>>>>>> e914bf3781c8444250ed99fa80aded092e6cafc6
  master_instance_type = "t3.medium"
  nodes_max_size = 1
  nodes_min_size = 1
  private_subnet01_netnum = "1"
  public_subnet01_netnum = "2"
  region = "eu-west-2"
  vpc_cidr_block = "10.240.0.0/16"
  worker_instance_type = "t3.medium"
  vpc_name = "kubernetes"
<<<<<<< HEAD
  ssh_public_key = # Add your public SSH key
=======
  ssh_public_key = # You SSH public key
>>>>>>> e914bf3781c8444250ed99fa80aded092e6cafc6
}
