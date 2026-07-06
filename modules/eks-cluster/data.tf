data "aws_caller_identity" "current" {}

data "aws_ami" "eks" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }

  owners = var.eks_ami_owner_ids
}

data "aws_iam_role" "eks" {
  name = var.eks_iam_role
}

data "aws_iam_role" "eks_worker" {
  name = var.node_group_iam_role
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "public" {
  count = length(var.public_subnet_ids)
  id    = var.public_subnet_ids[count.index]
}

data "aws_subnet" "private" {
  count = length(var.private_subnet_ids)
  id    = var.private_subnet_ids[count.index]
}

data "aws_internet_gateway" "all" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_route_table" "all" {
  for_each = { for subnet in var.public_subnet_ids : subnet => subnet }

  vpc_id    = var.vpc_id
  subnet_id = each.value
}
