#Create Security Group for EKS cluster
resource "aws_security_group" "security_group_eks_cluster" {
  name        = "${var.cluster_name}_sg_eks_cluster"
  description = "${var.description_sg_eks_cluster}"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
      for_each = var.port_range_sg_eks_cluster
      content {
          description      = "${var.description_sg_eks_cluster}"
          from_port        = ingress.value
          to_port          = ingress.value
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
      }
  }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  tags                                           = {
    Name                                         = "${var.cluster_name}_sg_eks_cluster"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}

#Create Security Group for EKS cluster
resource "aws_security_group" "security_group_ec2_worker_node" {
  name        = "${var.cluster_name}_sg_ec2_worker_node"
  description = "${var.description_sg_ec2_worker_node}"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
      for_each = var.port_range_sg_ec2_worker_node
      content {
          description      = "${var.description_sg_ec2_worker_node}"
          from_port        = ingress.value
          to_port          = ingress.value
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
      }
  }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  tags                                           = {
    Name                                         = "${var.cluster_name}_sg_ec2_worker_node"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}