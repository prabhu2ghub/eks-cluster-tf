variable "eks_k8s_version" {
  type        = string
  description = "Version of k8s to use in EKS"
  default     = "1.28"
}

variable "name" {
  type        = string
  description = "Name for deployment"
  default     = "dev"
}

variable "node_group_disk_size" {
  type        = number
  description = "Size of the instance disks in the local cluster"
  default     = 30
}

variable "node_group_instance_type" {
  type        = string
  description = "Instance type for the local cluster"
  default     = "t3.medium"
}

variable "node_group_desired_size" {
  type        = number
  description = "Number of instances desired in the local cluster"
  default     = 3
}

variable "node_group_max_size" {
  type        = number
  description = "Maximum number of instances allowed in the local cluster"
  default     = 3
}

variable "node_group_min_size" {
  type        = number
  description = "Minimum number of instances allowed in the local cluster"
  default     = 3
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "node_group_count" {
  type        = number
  description = "Number of node groups to create for this EKS cluster"
  default     = 1
}

variable "eks_iam_role" {
  type        = string
  description = "Name of the IAM service role to use for the EKS cluster."
}

variable "node_group_iam_role" {
  type        = string
  description = "Name of the IAM service role to use for the EKS node groups."
}

variable "eks_cluster_tags" {
  type        = map(any)
  default     = {}
  description = "Custom tags for the EKS cluster itself"
}

variable "eks_node_group_tags" {
  type        = map(any)
  default     = {}
  description = "Custom tags for the EKS managed node groups"
}

variable "eks_shared_tags" {
  type        = map(any)
  default     = {}
  description = "Custom tags shared by the EKS cluster and the node groups"
}

variable "eks_kms_keys" {
  type        = list(any)
  default     = []
  description = "List of KMS key ARNs to use for encrypting secrets"
}

variable "create_kms_key" {
  type        = bool
  default     = false
  description = "Create a KMS key for the EKS cluster to use for encrypting secrets"
}

variable "use_calico_networking" {
  type        = bool
  default     = false
  description = "Use Calico networking for EKS instead of AWS native (which uses IP space in subnets)"
}

variable "docker_mirror" {
  type        = string
  description = "URL of Docker registry mirror to pass to the EKS node group kubelet args"
  default     = ""
}

variable "force_update_version" {
  type        = bool
  description = "Force version update of node group if existing pods are unable to be drained due to a pod disruption budget issue."
  default     = true
}

variable "ami_id" {
  type        = string
  description = "Override the AMI ID used in a custom launch template. If not specified, a search will be performed."
  default     = ""
}

variable "eks_ami_owner_ids" {
  type        = list(string)
  description = "AWS account IDs trusted for the EKS optimized AMI lookup."
  default     = ["602401143452"]
}

variable "external_access_cidrs" {
  type = list(string)
}

variable "external_access_ipv6_cidrs" {
  type    = list(string)
  default = []
}

variable "vpc_id" {
  description = "The ID of the existing VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the existing public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The IDs of the existing private subnets"
  type        = list(string)
}

variable "github_username" {
  description = "The token username for GitHub authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_password" {
  description = "The password or token value for GitHub authentication"
  type        = string
  default     = ""
  sensitive   = true
}
variable "node_lt_path" {
  type        = string
  description = "provide path to the launch template userdata"
  #default = "${path.module}/templates/lt-userdata.tpl" 
}
variable "ec2key_name" {
  type        = string
  description = "provide value to the EC2 key pair for the launch template"
}

variable "policy_arns" {
  description = "A list of EKS access policies to associate with the EKS cluster"
  type        = list(string)
  default = [
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy",
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  ]
}

variable "cluster_admin_principal_arns" {
  description = "IAM principal ARNs granted admin access to the EKS cluster."
  type        = list(string)
  default     = []
}

variable "delete_protection" {
  type        = bool
  description = "Enable/Disable Termination Protection for the EKS cluster"
  default     = true
}
