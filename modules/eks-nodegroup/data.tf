data "aws_eks_cluster" "mytf_eks_cluster" {
  name = var.cluster_name
}

data "aws_iam_role" "eks_worker" {
  name = var.node_group_iam_role
}
