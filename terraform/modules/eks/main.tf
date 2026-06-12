#-------IAM Role for EKS Cluster ---------
resource "aws_iam_role" "cluster" {
  name = "${var.Three-tier-app}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# -------------creating The EKS Cluster ------------------------
resource "aws_eks_cluster" "main" {
  name     = "${var.Three-tier-app}-cluster"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

#----------IAM Role for Worker Nodes----------------------
resource "aws_iam_role" "nodes" {
  name = "${var.Three-tier-app}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

#------------creating Node Group----------------------
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.Three-tier-app}-nodes"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr,
    aws_iam_role_policy_attachment.node_s3,
  ]
}


#Create the S3 Inline/Custom Policy for your bucket
resource "aws_iam_policy" "eks_s3_upload_policy" {
  name        = "${var.Three-tier-app}-s3-upload-policy"
  description = "Allows EKS worker nodes to upload images to the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        # Replace "your-actual-s3-bucket-name" with your variable or bucket resource name
        Resource = "arn:aws:s3:::eks-app-uploads-2026/uploads/*"
      }
    ]
  })
}

# 2. Attach the S3 Policy to your existing worker node role
resource "aws_iam_role_policy_attachment" "node_s3" {
  policy_arn = aws_iam_policy.eks_s3_upload_policy.arn
  role       = aws_iam_role.nodes.name
}
