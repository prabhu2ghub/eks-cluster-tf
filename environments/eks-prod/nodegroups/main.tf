terraform {
  backend "s3" {
    bucket         = "example-terraform-state-bucket"
    key            = "eks-prod/nodegroups/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-terraform-locks"
  }
  required_version = ">= 1.6"
}

module "node_group" {
  source                   = "../../../modules/eks-nodegroup"
  cluster_name             = var.cluster_name
  node_group_name          = var.node_group_name
  node_group_disk_size     = var.node_group_disk_size
  node_group_instance_type = var.node_group_instance_type
  node_group_max_size      = var.node_group_max_size
  node_group_min_size      = var.node_group_min_size
  node_group_desired_size  = var.node_group_desired_size
  node_group_count         = var.node_group_count
  aws_region               = var.aws_region
  node_group_iam_role      = var.node_group_iam_role
  eks_node_group_tags = {
    Name        = var.node_group_name
    Region      = var.aws_region
    Environment = var.environment
    Product     = var.product
    CostCenter  = var.cost_center
  }
  force_update_version = var.force_update_version
  ami_id               = var.ami_id
  private_subnet_ids   = var.private_subnet_ids
  ec2key_name          = var.ec2key_name
  node_lt_path         = "./base-lt-userdata.tpl"

  node_taints = var.node_taints
}
