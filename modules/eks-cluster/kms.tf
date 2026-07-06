resource "aws_kms_key" "kms_key" {
  #checkov:skip=CKV2_AWS_64:kms key policy isn't required for demo
  count = var.create_kms_key ? 1 : 0

  description         = "${local.name} EKS Cluster Key"
  enable_key_rotation = true

  tags = merge({ Name = "${local.name}-kms-key" }, local.eks_cluster_tags)
}
