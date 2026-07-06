variable "aws_region" {
  description = "AWS Region where the node group is deployed."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "product" {
  description = "Product or platform name used in resource tags."
  type        = string
}

variable "cost_center" {
  description = "Cost center or billing tag value."
  type        = string
}

variable "cluster_name" {
  description = "Existing EKS cluster name."
  type        = string
}

variable "node_group_name" {
  description = "Managed node group name."
  type        = string
}

variable "node_group_iam_role" {
  description = "Existing IAM role name used by worker nodes."
  type        = string
}

variable "private_subnet_ids" {
  description = "Existing private subnet IDs for worker nodes."
  type        = list(string)
}

variable "ami_id" {
  description = "Optional EKS worker node AMI ID."
  type        = string
  default     = ""
}

variable "ec2key_name" {
  description = "Existing EC2 key pair name for worker node SSH access."
  type        = string
}

variable "node_group_instance_type" {
  description = "EC2 instance type for the managed node group."
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

variable "node_group_count" {
  description = "Number of managed node groups to create."
  type        = number
  default     = 1
}

variable "force_update_version" {
  description = "Force node group version updates when pods cannot be drained."
  type        = bool
  default     = true
}

variable "node_taints" {
  description = "Optional taints applied to the managed node group."
  type = list(object({
    key    = string
    value  = optional(string, null)
    effect = optional(string, "NO_SCHEDULE")
  }))
  default = []
}
