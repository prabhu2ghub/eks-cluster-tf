resource "aws_iam_role" "mytf_eks_worker_role" {
  name = "${var.product}-${var.env}-eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name        = "${var.product}-${var.env}-eks-worker-role"
    Environment = var.env
    Product     = var.product
  }
}

resource "aws_iam_role_policy_attachment" "mytf_eks_worker_role_policy" {
  role       = aws_iam_role.mytf_eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "mytf_eks_cni_policy" {
  role       = aws_iam_role.mytf_eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "mytf_eks_registry_policy" {
  role       = aws_iam_role.mytf_eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "mytf_s3_read_policy" {
  role       = aws_iam_role.mytf_eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
resource "aws_iam_role_policy" "CustomInstanceModifyPolicy" {
  name = "CustomInstanceModifyPolicy"
  role = aws_iam_role.mytf_eks_worker_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DetachVolume",
          "ec2:AttachVolume",
          "ec2:DeleteVolume",
          "ec2:ModifyVolume",
          "ec2:ModifyInstanceMetadataOptions",
          "ec2:ModifyVolumeAttribute",
          "ec2:DeleteTags",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones"
        ]
        "Resource" : [
          "*",
          "arn:aws:route53:::hostedzone/*"
        ]
      },
    ]
  })
}
