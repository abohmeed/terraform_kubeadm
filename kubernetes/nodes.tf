resource "aws_key_pair" "sshkey" {
  public_key = var.ssh_public_key
  key_name   = "mysshkey"
}
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.bastion_node.id]
  key_name               = aws_key_pair.sshkey.key_name
  subnet_id              = aws_subnet.utility.id
  root_block_device {
    volume_size = 20
  }
  tags = {
    Name = "bastion.${var.cluster_name}"
  }
}
resource "aws_lb" "api-k8s-local" {
  name               = "api-${var.cluster_name}"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public01.id]
  tags = {
    KubernetesCluster                           = var.cluster_name
    Name                                        = "api.${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
resource "aws_lb_listener" "k8s-api" {
  load_balancer_arn = aws_lb.api-k8s-local.arn
  port              = "6443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.control-plane.arn
  }
}
resource "aws_lb_target_group" "control-plane" {
  name     = "control-plane"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}
# resource "aws_elb" "api-k8s-local" {
#   name = "api-${var.cluster_name}"

#   listener {
#     instance_port     = 6443
#     instance_protocol = "TCP"
#     lb_port           = 6443
#     lb_protocol       = "TCP"
#   }

#   security_groups = [aws_security_group.api-elb-k8s-local.id]
#   subnets         = [aws_subnet.public01.id]

#   health_check {
#     target              = "SSL:6443"
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     interval            = 10
#     timeout             = 5
#   }

#   cross_zone_load_balancing = true
#   idle_timeout              = 300

#   tags = {
#     KubernetesCluster                           = var.cluster_name
#     Name                                        = "api.${var.cluster_name}"
#     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#   }
# }
resource "aws_launch_configuration" "masters-az01-k8s-local" {
  name_prefix          = "masters.${var.cluster_name}"
  image_id             = var.ami
  instance_type        = var.master_instance_type
  key_name             = aws_key_pair.sshkey.key_name
  iam_instance_profile = aws_iam_instance_profile.terraform_k8s_master_role-Instance-Profile.id
  security_groups      = [aws_security_group.k8s_master_nodes.id]
  user_data            = <<EOT
#!/bin/bash
hostnamectl set-hostname --static "$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)"
EOT
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "master-k8s-local-01" {
  name                 = "${var.cluster_name}_masters"
  launch_configuration = aws_launch_configuration.masters-az01-k8s-local.id
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.private01.id]
  target_group_arns    = [aws_lb_target_group.control-plane.arn]

  tags = [{
    key                 = "KubernetesCluster"
    value               = var.cluster_name
    propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "masters.${var.cluster_name}"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/role/master"
      value               = "1"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "1"
      propagate_at_launch = true
    }
  ]
}


resource "aws_launch_configuration" "worker-nodes-k8s-local" {
  name_prefix          = "nodes.${var.cluster_name}."
  image_id             = var.ami
  instance_type        = var.worker_instance_type
  key_name             = aws_key_pair.sshkey.key_name
  iam_instance_profile = aws_iam_instance_profile.terraform_k8s_worker_role-Instance-Profile.id
  security_groups      = [aws_security_group.k8s_worker_nodes.id]
  user_data            = <<EOT
#!/bin/bash
hostnamectl set-hostname --static "$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)"
EOT
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }
}
resource "aws_autoscaling_group" "nodes-k8s" {
  name                 = "${var.cluster_name}_workers"
  launch_configuration = aws_launch_configuration.worker-nodes-k8s-local.id
  max_size             = var.nodes_max_size
  min_size             = var.nodes_min_size
  vpc_zone_identifier  = [aws_subnet.private01.id]
  tags = [
    {
      key                 = "KubernetesCluster"
      value               = var.cluster_name
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "nodes.${var.cluster_name}"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/role/node"
      value               = "1"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "1"
      propagate_at_launch = true
    }
  ]
}
