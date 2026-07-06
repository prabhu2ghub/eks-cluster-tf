variable "aws_region" {
  description = "AWS Region where the EKS cluster is deployed."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "product" {
  description = "Product or platform name used in resource naming and tags."
  type        = string
}

variable "cost_center" {
  description = "Cost center or billing tag value."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "eks_k8s_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID where the EKS cluster will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "Existing private subnet IDs for worker nodes."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Existing public subnet IDs used by the EKS control plane."
  type        = list(string)
}

variable "external_access_cidrs" {
  description = "CIDR ranges allowed to reach the public EKS API endpoint."
  type        = list(string)
}

variable "cluster_admin_principal_arns" {
  description = "IAM principal ARNs granted admin access to the EKS cluster."
  type        = list(string)
  default     = []
}

variable "ami_id" {
  description = "Optional EKS worker node AMI ID. Leave empty to use the module AMI lookup."
  type        = string
  default     = ""
}

variable "ec2key_name" {
  description = "Existing EC2 key pair name for worker node SSH access."
  type        = string
}

variable "node_group_instance_type" {
  description = "EC2 instance type for the default managed node group."
  type        = string
}

variable "node_group_desired_size" {
  description = "Desired worker node count."
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum worker node count."
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum worker node count."
  type        = number
}

variable "node_group_disk_size" {
  description = "Worker node root disk size in GiB."
  type        = number
}
