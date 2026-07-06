output "cluster_role" {
  value = aws_iam_role.mytf_eks_cluster_role.name
}

output "worker_role" {
  value = aws_iam_role.mytf_eks_worker_role.name
}