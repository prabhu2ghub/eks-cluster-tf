
output "eks_endpoint" {
  value       = aws_eks_cluster.mytf_eks_cluster.endpoint
  description = "API endpoint for the EKS cluster"
}

output "eks_kubeconfig_file" {
  value       = "${path.root}/outputs/${local.name}_kube_config_cluster.yml"
  description = "Path to the config file for the EKS cluster"
  depends_on  = [local_file.kubeconfig]
}

output "public_subnets" {
  value = local.public_subnets
}

output "aws_route_tables" {
  value = data.aws_route_table.all
}

output "aws_internet_gateways" {
  value = data.aws_internet_gateway.all
}
