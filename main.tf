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
  ami = "ami-0ac72a68f7f5b2884"
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
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7kyzmKjjV+J7OTULE7G1JcJOaF4iwNqWhCEXl7h7600w6jtNPi1COJdM4dZX+Hdxkr92mqGgbjX4N3ZXFvN51MpGIca+f9Bvz6D6ggnJWRl5j/8L+iBhSUnUrL8EP8iXWMyhopff2INzykNJkECjUg6ChbwGs2DapwtviCp0IHIFpenw7uvpCfyXcgl7bVWUao35Zc2zc5n7TQ3fXFN254dOfANU3ukR2824IKkjO1rEbLdPw/7k/3l2C3FsbuK0bw43ffm1QRfAcSUstxNOkeWqbAQqEGxL0m136IfeoQcHLlH8hQLb0aQaKvijKpCmEpc8eEUh5lVYNF96Gkst7"
}
