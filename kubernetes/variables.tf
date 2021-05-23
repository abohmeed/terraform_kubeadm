variable "vpc_cidr_block" {
  type = string
}
variable "vpc_name" {
  type = string
}
variable "region" {
  type = string
}
variable "private_subnet01_netnum" {
  type = string
}
variable "public_subnet01_netnum" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "ami" {
  type = string
}
variable "master_instance_type" {
  type = string
}
variable "worker_instance_type" {
  type = string
}
variable "nodes_max_size" {
  type = number
}
variable "nodes_min_size" {
  type = number
}