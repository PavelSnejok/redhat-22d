# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags                                           = {
    Name                                         = "${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}

# Create an IG
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

  tags                                           = {
    Name                                         = "igw-${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}

# Create a Public Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }

  tags                                           = {
    Name                                         = "Public-Rout-Table-${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
  depends_on = [ aws_internet_gateway.igw ]
}

# Create 3 Public Subnets with resources and Depending resources on it
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id

  # Requered for EKS. Instance launched into the subnet should be assigned a public IP
  map_public_ip_on_launch = true

  count = 3
  cidr_block = "${cidrsubnet(var.vpc_cidr, 8, var.puclic_subnet_offset + count.index)}"
  availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)

  tags                                           = {
    Name                                         = "Public_Subnet_#${var.puclic_subnet_offset + count.index}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }

    depends_on = [ aws_internet_gateway.igw, aws_route_table.public_route_table ]
}

# Associate Public Subnets with a Route Table for Internet access to it
resource "aws_route_table_association" "public_subnet_association" {
    for_each = {for i, subnet in aws_subnet.public_subnet : i => subnet.id}
    subnet_id      = each.value
    route_table_id = aws_route_table.public_route_table.id
}

# Crete a Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.vpc.id

  tags                                           = {
    Name                                         = "Private-Rout-Table-${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
  depends_on = [ aws_internet_gateway.igw ]
}

#Create 3 Private Subnets with resources and Depending resources on it
resource "aws_subnet" "private_subnet" {
    vpc_id     = aws_vpc.vpc.id

    count = 3
    cidr_block = "${cidrsubnet(var.vpc_cidr, 8, var.private_subnet_offset + count.index)}"
    availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
    
  tags                                           = {
    Name                                         = "Private_Subnet_#${var.private_subnet_offset + count.index}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }

    depends_on = [ aws_route_table.private_route_table ]
}

# Associate Private Subnets with a Route Table
resource "aws_route_table_association" "private_subnet_association" {
    for_each = {for i, subnet in aws_subnet.private_subnet : i => subnet.id}
    subnet_id      = each.value
    route_table_id = aws_route_table.private_route_table.id
}