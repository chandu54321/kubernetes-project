resource "aws_vpc" "first" {
  cidr_block         = var.aws_vpc.cidr_block
  enable_dns_support = var.aws_vpc.enable_dns_support
  tags               = var.aws_vpc.tags
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.subnet_public)
  vpc_id            = aws_vpc.first.id
  cidr_block        = var.subnet_public[count.index].cidr_block
  availability_zone = var.subnet_public[count.index].availability_zone
  tags              = var.subnet_public[count.index].tags
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.subnet_private)
  vpc_id            = aws_vpc.first.id
  cidr_block        = var.subnet_private[count.index].cidr_block
  availability_zone = var.subnet_private[count.index].availability_zone
  tags              = var.subnet_private[count.index].tags
}

resource "aws_internet_gateway" "forvpc" {
  vpc_id = aws_vpc.first.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.first.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.forvpc.id
  }
  tags = {
    name = "publicroutetable"
  }
}

resource "aws_route_table_association" "publicass" {
  count          = length(var.subnet_public)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Create IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eksrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

# Attach Policies to IAM Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "first"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = aws_subnet.private_subnet[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy_attachment]
}

resource "aws_iam_role" "eks_node_role" {
  name = "EKSNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach necessary policies to the Node Group role
resource "aws_iam_role_policy_attachment" "worker_node_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "registry_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# Create EKS Node Group
resource "aws_launch_template" "example1" {
  name_prefix = "example-"

  # Specify your instance type here
  instance_type = "t2.medium"


  # Other con  figurations (like AMI, security groups) can go here
}

resource "aws_eks_node_group" "main1" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "firstgroup"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  launch_template {
    id      = aws_launch_template.example1.id
    version = "$Latest"
  }

  subnet_ids = aws_subnet.private_subnet[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

resource "aws_launch_template" "example2" {
  name_prefix = "example-"

  # Specify your instance type here
  instance_type = "t2.medium"


  # Other con  figurations (like AMI, security groups) can go here
}

resource "aws_eks_node_group" "main2" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "secondgroup"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  launch_template {
    id      = aws_launch_template.example2.id
    version = "$Latest"
  }

  subnet_ids = aws_subnet.private_subnet[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}
resource "aws_launch_template" "example3" {
  name_prefix = "example-"

  # Specify your instance type here
  instance_type = "r3.large"


  # Other con  figurations (like AMI, security groups) can go here
}

resource "aws_eks_node_group" "main3" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "thirdgroup"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  launch_template {
    id      = aws_launch_template.example3.id
    version = "$Latest"
  }

  subnet_ids = aws_subnet.private_subnet[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}