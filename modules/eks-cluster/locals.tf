locals {
  account_id = data.aws_caller_identity.current.account_id

  name = var.name

  ami_id = var.ami_id == "" ? data.aws_ami.eks.id : var.ami_id

  created_key_arn = var.create_kms_key ? [aws_kms_key.kms_key[0].arn] : []
  kms_keys        = length(var.eks_kms_keys) > 0 ? var.eks_kms_keys : local.created_key_arn

  eks_cluster_tags    = merge(var.eks_shared_tags, var.eks_cluster_tags)
  eks_node_group_tags = merge(var.eks_shared_tags, var.eks_node_group_tags)

  oidc_provider = trimprefix(aws_eks_cluster.mytf_eks_cluster.identity[0].oidc[0].issuer, "https://")

  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl", {
    kubeconfig_name                = var.name
    endpoint                       = aws_eks_cluster.mytf_eks_cluster.endpoint
    cluster_auth_base64            = aws_eks_cluster.mytf_eks_cluster.certificate_authority[0].data
    aws_authenticator_command      = "aws"
    aws_authenticator_command_args = ["--region", var.aws_region, "eks", "get-token", "--cluster-name", aws_eks_cluster.mytf_eks_cluster.name]
  })

  # Assuming a subnet is public if any of its route tables have a route to an Internet Gateway
  public_subnets = { for rt in data.aws_route_table.all : rt.subnet_id => rt if can(rt.routes) && anytrue([for r in rt.routes : contains([data.aws_internet_gateway.all.internet_gateway_id], r.gateway_id)]) }

  # All subnets that are not public are considered private
  private_subnets = [for s in data.aws_subnets.all.ids : s if !contains(keys(local.public_subnets), s)]
}
