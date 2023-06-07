# Create IAM Role for EKS cluster (contains: aws_iam_role, aws_iam_policy_document, aws_iam_role_policy_attachment)
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}_eks_role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_role_json.json

  tags                                           = {
    Name                                         = "${var.cluster_name}_eks_role"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}

data "aws_iam_policy_document" "eks_cluster_role_json" {
  statement {
      effect = "Allow"

      principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
      }

      actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_AmazonEKSClusterPolicy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  ])
  policy_arn = each.value
  role       = aws_iam_role.eks_cluster_role.name
}

# Create EC2 Role for EKS cluster (contains: aws_iam_role, aws_iam_policy_document, aws_iam_role_policy_attachment)
resource "aws_iam_role" "ec2_cluster_role" {
  name = "${var.cluster_name}_ec2_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_cluster_role_json.json

  tags                                           = {
    Name                                         = "${var.cluster_name}_ec2_role"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}

data "aws_iam_policy_document" "ec2_cluster_role_json" {
  statement {
      effect = "Allow"

      principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
      }

      actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ec2_cluster_role_AmazonEKSWorkerNodePolicy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ])
  policy_arn = each.value
  role       = aws_iam_role.ec2_cluster_role.name
}

