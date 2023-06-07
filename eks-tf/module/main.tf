provider "aws" {
    region = var.region
}

module "sample_eks_cluster" {
  source                          = "../templates"
  # EKS-cluster variables
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version

  #EC2-instance variables
  desired_size_ec2                = var.desired_size_ec2
  max_size_ec2                    = var.max_size_ec2
  min_size_ec2                    = var.min_size_ec2
  image_id_ec2                    = var.image_id_ec2
  capacity_type_ec2               = var.capacity_type_ec2
  disk_size_ec2                   = var.disk_size_ec2
  instance_type_ec2               = var.instance_type_ec2

  # Securirty Group variables
  description_sg_eks_cluster      = var.description_sg_eks_cluster
  port_range_sg_eks_cluster       = var.port_range_sg_eks_cluster

  description_sg_ec2_worker_node  = var.description_sg_ec2_worker_node
  port_range_sg_ec2_worker_node   = var.port_range_sg_ec2_worker_node

  # VPC variables
  vpc_cidr                        = var.vpc_cidr
  puclic_subnet_offset            = var.puclic_subnet_offset
  private_subnet_offset           = var.private_subnet_offset

  # IAM variables

}

# module "self_managed_node_group" {
#   source = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"

#   name                = "separate-self-mng"
#   cluster_name        = "${var.cluster_name}"
#   cluster_version     = var.cluster_version
#   # cluster_endpoint    = "https://012345678903AB2BAE5D1E0BFE0E2B50.gr7.us-east-1.eks.amazonaws.com"
#   # cluster_auth_base64 = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKbXFqQ1VqNGdGR2w3ZW5PeWthWnZ2RjROOTVOUEZCM2o0cGhVZUsrWGFtN2ZSQnZya0d6OGxKZmZEZWF2b2plTwpQK2xOZFlqdHZncmxCUEpYdHZIZmFzTzYxVzdIZmdWQ2EvamdRM2w3RmkvL1dpQmxFOG9oWUZkdWpjc0s1SXM2CnNkbk5KTTNYUWN2TysrSitkV09NT2ZlNzlsSWdncmdQLzgvRU9CYkw3eUY1aU1hS3lsb1RHL1V3TlhPUWt3ZUcKblBNcjdiUmdkQ1NCZTlXYXowOGdGRmlxV2FOditsTDhsODBTdFZLcWVNVlUxbjQyejVwOVpQRTd4T2l6L0xTNQpYV2lXWkVkT3pMN0xBWGVCS2gzdkhnczFxMkI2d1BKZnZnS1NzWllQRGFpZTloT1NNOUJkNFNPY3JrZTRYSVBOCkVvcXVhMlYrUDRlTWJEQzhMUkVWRDdCdVZDdWdMTldWOTBoL3VJUy9WU2VOcEdUOGVScE5DakszSjc2aFlsWm8KWjNGRG5QWUY0MWpWTHhiOXF0U1ROdEp6amYwWXBEYnFWci9xZzNmQWlxbVorMzd3YWM1eHlqMDZ4cmlaRUgzZgpUM002d2lCUEVHYVlGeWN5TmNYTk5aYW9DWDJVL0N1d2JsUHAKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ=="

#   # subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

#   # // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
#   # // Without it, the security groups of the nodes are empty and thus won't join the cluster.
#   # vpc_security_group_ids = [
#   #   module.eks.cluster_primary_security_group_id,
#   #   module.eks.cluster_security_group_id,
#   # ]
#   # min_size     = 1
#   # max_size     = 10
#   # desired_size = 1

#   launch_template_name   = "${var.cluster_name}_ec2_worker_launch_template"
#   # instance_type          = "m5.large"

#   # tags = {
#   #   Environment = "dev"
#   #   Terraform   = "true"
#   # }
# }