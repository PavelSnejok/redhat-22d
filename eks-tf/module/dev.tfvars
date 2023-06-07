    # For main.tf file
# Provider AWS
region = "us-east-1"

    # For eks.tf file
#EKS cluster name
cluster_name = "sample_eks_dev"

# Cluster version
cluster_version = "1.23"

# EC2 instance Desired size for worker nodes
desired_size_ec2 = 1

# EC2 instance Max size for worker nodes
max_size_ec2 = 1

# EC2 instance Min size for worker nodes
min_size_ec2 = 1

# EC2 AIM Type for worker nodes
image_id_ec2 = "ami-006896008e984456c"

# EC2 AIM Type for worker nodes
capacity_type_ec2 = "MIXED"

# EC2 AIM Type for worker nodes
disk_size_ec2 = 20

# EC2 AIM Type for worker nodes
instance_type_ec2 = "t3.medium"

    # For sg.tf file
# Security Group Description for EKS cluster for example "Allow_..."
description_sg_eks_cluster = "Allow_HTTP_HTTPS_SSH"

# Security Group Port Range for EKS cluster for example "[22, 80, 443, ..]"
port_range_sg_eks_cluster = [ 22, 80, 443, 6443, 10259, 10257, 2379, 2380, 10250 ]

# Security Group Description for EC2 Worker Nodes for example "Allow_..."
description_sg_ec2_worker_node = "Allow_HTTP_HTTPS_SSH"

# Security Group Port Range for EC2 Worker Nodes for example "[22, 80, 443, ..]"
port_range_sg_ec2_worker_node = [ 22, 80, 443, 6443, 10259, 10257, 2379, 2380, 10250 ]

    # For vpc.tf file
#custom VPC for example "10.0.0.0/8"
vpc_cidr = "10.10.0.0/16"

# Custom Public Subnet offset for example "10.0.--.0/24"
puclic_subnet_offset = "21"

# Custom Private Subnet offset for example "10.0.--.0/24"
private_subnet_offset = "31"


