    # For eks.tf file
# Cluster name
variable cluster_name {
  type  =  string
}

# Cluster version
variable cluster_version {
  type  =  string
}

# EC2 instance Desired size
variable desired_size_ec2 {
  type  =  number
}

# EC2 instance Max size
variable max_size_ec2 {
  type  =  number
}

# EC2 instance Min size
variable min_size_ec2 {
  type  =  number
}

# EC2 AIM Type
variable image_id_ec2 {
  type  =  string
}

# EC2 AIM Type
variable capacity_type_ec2 {
  type  =  string
}

# EC2 AIM Type
variable disk_size_ec2 {
  type  =  number
}

# EC2 AIM Type
variable instance_type_ec2 {
  type  =  string
}

    # For sg.tf file
# Security Group Description for EKS cluster
variable description_sg_eks_cluster {
  type  =  string
}

# Security Group Port Range for EKS cluster
variable port_range_sg_eks_cluster {
  type  =  list(number)
}

# Security Group Description for EC2 worker node
variable description_sg_ec2_worker_node {
  type  =  string
}

# Security Group Port Range for EC2 worker node
variable port_range_sg_ec2_worker_node {
  type  =  list(number)
}

    # For vpc.tf file
# Custom VPC cidr
variable vpc_cidr {
  type  =  string
}

# Custom Public Subnet offset
variable puclic_subnet_offset {
  type  =  string
}

# Custom Private Subnet offset
variable private_subnet_offset {
  type  =  string
}
