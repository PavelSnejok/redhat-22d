# Create provider
provider "aws" {
    region = "us-east-1"
}

# Create a VPC for EKS-cluster
resource "aws_vpc" "pr_vpc" {
    cidr_block       = "10.10.0.0/16"

    #Make your instance shared on the host.
    instance_tenancy = "default"

    #Required for EKS. Enable/disable DNS support in the VPC.
    enable_dns_support = true

    # Requiered for EKS. Enable/disable DNS hostnames in the VPC.
    enable_dns_hostnames = true

    tags = {
        Name = "pr-vpc"
        terraform = "True"
  }
}

#Show project_vpc_id
output "output_pr-vpc" {
    value = aws_vpc.pr_vpc.id
    sensitive = false
}

# Create an IG
resource "aws_internet_gateway" "pr_igw" {
    vpc_id = aws_vpc.pr_vpc.id

    tags = {
        Name = "pr_igw"
        terraform = "True"
    }
}

#Crete a Route Table for Public subnets
resource "aws_route_table" "pr_public_route_table" {
    vpc_id = aws_vpc.pr_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.pr_igw.id
    }

    tags = {
        Name = "pr_public_route_table"
        terraform = "True"
    }
}

#Create 3 Public Subnets with resources and Depending resources on it
resource "aws_subnet" "pr_public_subnet" {
    vpc_id     = aws_vpc.pr_vpc.id

    #Requered for EKS. Instance launched into the subnet should be assigned a public IP
    map_public_ip_on_launch = true

    count = 3
    cidr_block = "10.10.${21 + count.index}.0/24"
    availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)

    tags = {
        Name = "pr_public_subnet_#${21 + count.index}"
        terraform = "True"
    }

    depends_on = [ aws_internet_gateway.pr_igw, aws_route_table.pr_public_route_table ]
}

# Output pr_public_subnet.id
output "output_pr_public_subnet" {
    value = {for i, subnet in aws_subnet.pr_public_subnet : i => subnet.id}
}

# Associate Public Subnets with a Route Table for Internet access to it
resource "aws_route_table_association" "pr_public_subnet_association" {
    for_each = {for i, subnet in aws_subnet.pr_public_subnet : i => subnet.id}
    subnet_id      = each.value
    route_table_id = aws_route_table.pr_public_route_table.id
}

# Crete a Route Table for Private subnets
resource "aws_route_table" "pr_private_route_table" {
    vpc_id = aws_vpc.pr_vpc.id

    tags = {
        Name = "pr_private_route_table"
        terraform = "True"
    }
}

#Create 3 Private Subnets with resources and Depending resources on it
resource "aws_subnet" "pr_private_subnet" {
    vpc_id     = aws_vpc.pr_vpc.id

    count = 3
    cidr_block = "10.10.${31 + count.index}.0/24"
    availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
    
    tags = {
        Name = "pr_rivate_subnet_#${31 + count.index}"
        terraform = "True"
    }

    depends_on = [ aws_route_table.pr_public_route_table ]
}

# Output pr_private_subnet.id
output "output_pr_private_subnet" {
    value = {for i, subnet in aws_subnet.pr_private_subnet : i => subnet.id}
}

# Associate Private Subnets with a Route Table
resource "aws_route_table_association" "pr_private_subnet_association" {
    for_each = {for i, subnet in aws_subnet.pr_private_subnet : i => subnet.id}
    subnet_id      = each.value
    route_table_id = aws_route_table.pr_private_route_table.id
}




#Create IAM Role for EKS policy
data "aws_iam_policy_document" "pr_eks_cluster_role_json" {
    statement {
        effect = "Allow"

        principals {
        type        = "Service"
        identifiers = ["eks.amazonaws.com"]
        }

        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "pr_eks_cluster_role" {
    name               = "pr_eks_cluster_role"
    assume_role_policy = data.aws_iam_policy_document.pr_eks_cluster_role_json.json
    
    tags = {
        Name = "pr_eks_cluster_role"
        terraform = "True"
    }
}

resource "aws_iam_role_policy_attachment" "pr_attachment_eks_cluster_role_policy" {
    for_each = toset([
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
        "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
        "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    ])
    policy_arn = each.value
    role       = aws_iam_role.pr_eks_cluster_role.name
}

#Create security group for EKS cluster
resource "aws_security_group" "pr_security_group_eks_cluster" {
    name        = "pr_security_group_eks_cluster"
    description = "Allow_HTTP_HTTPS_SSH"
    vpc_id      = aws_vpc.pr_vpc.id

    dynamic "ingress" {
        for_each = var.pr_port_range_sg_eks_cluster
        content {
            description      = "Allow_HTTP_HTTPS_SSH"
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

    tags = {
        Name = "pr_security_group_eks_cluster"
        terraform = "True"
    }
}

#Create variable numbers for ports
variable "pr_port_range_sg_eks_cluster" {
    type = list(number)
    default = [ 22, 80, 443, 6443, 10259, 10257, 2379, 2380, 10250 ]
}

#Create IAM Role for EC2 Worker Node policy
data "aws_iam_policy_document" "pr_ec2_worker_role_json" {
    statement {
        effect = "Allow"

        principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
        }

        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "pr_ec2_worker_role" {
    name               = "pr_ec2_worker_role"
    assume_role_policy = data.aws_iam_policy_document.pr_ec2_worker_role_json.json
    
    tags = {
        Name = "pr_ec2_worker_role"
        terraform = "True"
    }
}

resource "aws_iam_role_policy_attachment" "pr_attachment_ec2_worker_role_policy" {
    for_each = toset([
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ])
    policy_arn = each.value
    role       = aws_iam_role.pr_ec2_worker_role.name
}

# Create EKS cluster
resource "aws_eks_cluster" "pr_eks_cluster" {
    name     = "pr_eks_cluster"
    version = 1.23
    role_arn = aws_iam_role.pr_eks_cluster_role.arn

    vpc_config {
        subnet_ids = [for subnet in aws_subnet.pr_public_subnet : subnet.id]
        security_group_ids = [aws_security_group.pr_security_group_eks_cluster.id]
        # Indicates whether or not the Amazone EKS private API server endpoint is enabled.
        endpoint_private_access = true
        endpoint_public_access = true
    }

    tags = {
        Name = "pr_eks_cluster"
        terraform = "True"
    }
    # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
    # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.

    depends_on = [
        aws_iam_role_policy_attachment.pr_attachment_eks_cluster_role_policy,
        aws_subnet.pr_public_subnet,
        aws_security_group.pr_security_group_eks_cluster
    ]
}

resource "aws_eks_node_group" "pr_node_eks_ec2" {
    cluster_name    = aws_eks_cluster.pr_eks_cluster.name
    node_group_name = "pr_node_eks_ec2"
    node_role_arn   = aws_iam_role.pr_ec2_worker_role.arn
    subnet_ids      = [for subnet in aws_subnet.pr_public_subnet : subnet.id]

    scaling_config {
        desired_size = 1
        max_size     = 2
        min_size     = 1
    }

    ami_type = "AL2_x86_64"
    capacity_type = "ON_DEMAND"
    disk_size = 20
    force_update_version = false
    instance_types = ["t3.medium"]
    version = 1.23

    labels = {
      terraform = "true"
    }

    update_config {
        max_unavailable = 1
    }

    # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
    # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
    depends_on = [
        aws_iam_role_policy_attachment.pr_attachment_ec2_worker_role_policy
    ]
}
