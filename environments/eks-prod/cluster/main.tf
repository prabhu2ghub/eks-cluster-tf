terraform {
  backend "s3" {
    bucket         = "example-terraform-state-bucket"
    key            = "eks-prod/cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-terraform-locks"
  }
  required_version = ">= 1.6"
}

module "iam" {
  source  = "../../../modules/eks-iam"
  env     = var.environment
  product = var.product
}

module "eks_cluster" {
  source          = "../../../modules/eks-cluster"
  eks_k8s_version = var.eks_k8s_version

  name                         = var.cluster_name
  aws_region                   = var.aws_region
  vpc_id                       = var.vpc_id
  private_subnet_ids           = var.private_subnet_ids
  public_subnet_ids            = var.public_subnet_ids
  external_access_cidrs        = var.external_access_cidrs
  cluster_admin_principal_arns = var.cluster_admin_principal_arns

  eks_iam_role        = module.iam.cluster_role
  node_group_iam_role = module.iam.worker_role
  eks_cluster_tags = {
    Name = var.cluster_name
  }
  eks_node_group_tags = {
    Name = "${var.cluster_name}-nodegroup"
  }
  eks_shared_tags = {
    Region      = var.aws_region
    Environment = var.environment
    Product     = var.product
    CostCenter  = var.cost_center
  }
  ami_id                   = var.ami_id
  node_lt_path             = "./base-lt-userdata.tpl"
  ec2key_name              = var.ec2key_name
  node_group_instance_type = var.node_group_instance_type
  node_group_desired_size  = var.node_group_desired_size
  node_group_max_size      = var.node_group_max_size
  node_group_min_size      = var.node_group_min_size
  node_group_disk_size     = var.node_group_disk_size
}
