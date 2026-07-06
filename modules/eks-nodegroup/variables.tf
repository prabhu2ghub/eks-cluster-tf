variable "cluster_name" {
  type        = string
  description = "Provide name of the cluster where this node group to be created "
}

variable "node_group_name" {
  type        = string
  description = "Provide the desired name for the node group"

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

variable "node_group_iam_role" {
  type        = string
  description = "Name of the IAM service role to use for the EKS node groups."
}

variable "eks_node_group_tags" {
  type        = map(any)
  default     = {}
  description = "Custom tags for the EKS managed node groups"
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


variable "private_subnet_ids" {
  description = "The IDs of the existing private subnets"
  type        = list(string)
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

#Taint configuration variables -- this is optional 
variable "node_taints" {
  description = "List of taints to apply in the nodegroup"
  type = list(object({
    key    = string
    value  = optional(string, null)          #Optional with null default
    effect = optional(string, "NO_SCHEDULE") #optional with default to NO_SCHEDULE
  }))
  default = [] #makes entire list optional
}