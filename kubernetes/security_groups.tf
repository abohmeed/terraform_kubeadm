resource "aws_security_group" "api-elb-k8s-local" {
  name        = "api-elb.${var.cluster_name}.k8s.local"
  vpc_id      = aws_vpc.main.id
  description = "Security group for api ELB"
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3
    to_port     = 4
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    KubernetesCluster = "${var.cluster_name}.k8s.local"
    Name              = "api-elb.${var.cluster_name}.k8s.local"
  }
}
resource "aws_security_group" "bastion_node" {
  name        = "bastion_node"
  description = "Allow required traffic to the bastion node"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_bastion"
  }
}
resource "aws_security_group" "k8s_worker_nodes" {
  name        = "k8s_workers_${var.cluster_name}"
  description = "Worker nodes security group"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name                                        = "${var.cluster_name}_nodes"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group" "k8s_master_nodes" {
  name        = "k8s_masters_${var.cluster_name}"
  description = "Master nodes security group"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name                                        = "${var.cluster_name}_nodes"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "traffic_from_lb" {
  type                     = "ingress"
  description              = "Allow API traffic from the load balancer"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.api-elb-k8s-local.id
  security_group_id        = aws_security_group.k8s_master_nodes.id
}
resource "aws_security_group_rule" "traffic_from_workers_to_masters" {
  type                     = "ingress"
  description              = "Traffic from the worker nodes to the master nodes is allowed"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.k8s_master_nodes.id
  source_security_group_id = aws_security_group.k8s_worker_nodes.id
}
resource "aws_security_group_rule" "traffic_from_bastion_to_masters" {
  type                     = "ingress"
  description              = "Traffic from the bastion node to the master node is allowed"
  from_port                = 22
  to_port                  = 22
  protocol                 = "TCP"
  security_group_id        = aws_security_group.k8s_master_nodes.id
  source_security_group_id = aws_security_group.bastion_node.id
}

resource "aws_security_group_rule" "masters_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_master_nodes.id
}