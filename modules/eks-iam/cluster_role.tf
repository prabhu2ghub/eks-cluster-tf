resource "aws_iam_role" "mytf_eks_cluster_role" {
  name = "${var.product}-${var.env}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name        = "${var.product}-${var.env}-eks-cluster-role"
    Environment = var.env
    Product     = var.product
  }
}

resource "aws_iam_role_policy_attachment" "mytf_eks_cluster_role_policy" {
  role       = aws_iam_role.mytf_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
