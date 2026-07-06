#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "eks" {
  name        = "${local.name}-cluster-sg"
  description = "EKS cluster traffic"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "All Internal Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description      = "External TLS Traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.external_access_cidrs
    ipv6_cidr_blocks = var.external_access_ipv6_cidrs
  }

  # we're not restricting outbound yet
  egress {
    description      = "All Outbound Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({ Name = "${local.name}-cluster-sg" }, local.eks_cluster_tags)
}
