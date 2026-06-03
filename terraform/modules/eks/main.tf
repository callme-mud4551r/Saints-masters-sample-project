resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    var.cluster_policy_attachment
  ]

  tags = {
    Name = var.cluster_name
  }
}
