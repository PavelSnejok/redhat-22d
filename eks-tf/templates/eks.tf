# Create EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_name}"
  version = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
      subnet_ids = [for subnet in aws_subnet.public_subnet : subnet.id]
      security_group_ids = [aws_security_group.security_group_eks_cluster.id]
      # Indicates whether or not the Amazone EKS private API server endpoint is enabled.
      endpoint_private_access = true
      endpoint_public_access = true
  }
 
  tags                                           = {
    Name                                         = "${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_AmazonEKSClusterPolicy,
    aws_subnet.public_subnet,
    aws_security_group.security_group_eks_cluster
  ]
}

resource "aws_eks_addon" "eks_coredns" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "coredns"
  addon_version               = "v1.8.7-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

resource "aws_eks_addon" "eks_vpc_cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

resource "aws_eks_addon" "eks_kube_proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "kube-proxy"

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

resource "aws_eks_addon" "eks_ebs_csi_driver" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"
  addon_version = "v1.19.0-eksbuild.1"

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

##########################################

resource "aws_iam_instance_profile" "eks_ec2_instance_profile" {
  name = "${var.cluster_name}_ec2_instance_profile"
  role = aws_iam_role.ec2_cluster_role.name
}

resource "aws_launch_template" "ec2_worker_launch_template" {
  name_prefix   = "${var.cluster_name}_ec2_worker_launch_template"
  image_id      = var.image_id_ec2
  instance_type = var.instance_type_ec2

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_ec2_instance_profile.arn
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_type = "gp3"
      volume_size = 20
    }
  }

  user_data = base64encode(
    <<USERDATA
    #!/bin/bash
    /etc/eks/bootstrap.sh ${var.cluster_name} --container-runtime containerd
    USERDATA
  )

  metadata_options {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
  }

  tags                                           = {
    Name                                         = "${var.cluster_name}_ec2_instance"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }

}

resource "aws_autoscaling_group" "ec2_worker_autoscaling" {
  desired_capacity   = var.desired_size_ec2
  max_size           = var.max_size_ec2
  min_size           = var.min_size_ec2
  capacity_rebalance = true
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnet : subnet.id]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.ec2_worker_launch_template.id
          version = "$Latest"
        }
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
    }
  }

  tag                             {
    key                           = "Name"
    value                         = "${var.cluster_name}"
    propagate_at_launch           = true
  }

    tag                             {
    key                           = "kubernetes.io/cluster/${var.cluster_name}"
    value                         = "owned"
    propagate_at_launch           = true
  }

    tag                             {
    key                           = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value                         = "owned"
    propagate_at_launch           = true
  }

    tag                             {
    key                           = "k8s.io/cluster-autoscaler/enabled"
    value                         = "true"
    propagate_at_launch           = true
  }
}


################################

data "aws_eks_cluster" "data_eks_cluster" {
  name = "${var.cluster_name}"
  depends_on = [ aws_eks_cluster.eks_cluster ]
}

data "aws_eks_cluster_auth" "data_eks_cluster_auth" {
  name = "${var.cluster_name}"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.data_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.data_eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.data_eks_cluster_auth.token
}

resource "kubernetes_config_map" "config_map_aws_auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<-EOF
      - rolearn: ${data.aws_iam_role.ec2_cluster_role.arn}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
          - system:masters
    EOF
  }
}

data "aws_iam_role" "ec2_cluster_role" {
  name = "${var.cluster_name}_ec2_role"
  depends_on = [ aws_iam_role.ec2_cluster_role ]
}

###########################

# # Create EC2 Worker Node for EKS cluster
# resource "aws_eks_node_group" "eks_work_node_ec2" {
#     cluster_name    = aws_eks_cluster.eks_cluster.name
#     node_group_name = "${var.cluster_name}_work_node_ec2"
#     node_role_arn   = aws_iam_role.ec2_cluster_role.arn
#     subnet_ids      = [for subnet in aws_subnet.public_subnet : subnet.id]

#     scaling_config {
#         desired_size = var.desired_size_ec2
#         max_size     = var.max_size_ec2
#         min_size     = var.min_size_ec2
#     }

#     launch_template {
 
#     }

  

#     ami_type = var.aim_type_ec2
#     capacity_type = var.capacity_type_ec2
#     disk_size = var.disk_size_ec2
#     force_update_version = false
#     instance_types = var.instance_type_ec2
#     version = var.cluster_version
#     capacity = {

#     }

#   tags                                           = {
#     Name                                         = "${var.cluster_name}_worker_node"
#     "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
#   }

#     update_config {
#         max_unavailable = 1
#     }

#     # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#     # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#     depends_on = [
#         aws_iam_role_policy_attachment.ec2_cluster_role_AmazonEKSWorkerNodePolicy,
#         aws_eks_cluster.eks_cluster,
#         aws_security_group.security_group_ec2_worker_node
#     ]
# }