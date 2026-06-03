resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name

  node_role_arn = var.node_role_arn
  subnet_ids    = var.subnet_ids

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  instance_types = ["t3.micro"]
  capacity_type  = "ON_DEMAND"

  tags = {
    Name = var.node_group_name
  }
}
