# Output VPC id
output "output_vpc_id" {
    value = aws_vpc.vpc.id
    sensitive = false
}

# Output Public Subnet id
output "output_public_subnet" {
    value = {for i, subnet in aws_subnet.public_subnet : i => subnet.id}
}

# Output Private Subnet id
output "output_private_subnet" {
    value = {for i, subnet in aws_subnet.private_subnet : i => subnet.id}
}

# Output EKS-cluster role
output "output_eks_cluster_role" {
    value = aws_iam_role.eks_cluster_role.id
}

# Output EC2-worker-cluster role
output "output_ec2_cluster_role" {
    value = aws_iam_role.ec2_cluster_role.id
}

