# EKS Cluster Terraform

This repository contains a modular Terraform implementation for provisioning and managing Amazon EKS clusters across multiple environments.

The project is organized around reusable modules for IAM, EKS control plane resources, and managed node groups. Environment folders show how the modules can be composed for non-production, performance, and production-style deployments.

## What This Creates

- EKS cluster control plane
- EKS cluster IAM role
- Managed node group IAM role
- EKS managed node groups with launch templates
- Cluster security group rules
- Optional KMS key for Kubernetes secrets encryption
- CloudWatch control plane logging
- EKS access entries and policy associations
- Optional Calico networking installation

## Repository Structure

```text
.
├── environments/
│   ├── eks-nonprod/
│   ├── eks-perf/
│   └── eks-prod/
└── modules/
    ├── eks-cluster/
    ├── eks-iam/
    └── eks-nodegroup/
```

## Module Overview

### `modules/eks-iam`

Creates the IAM roles and policy attachments needed by the EKS control plane and worker nodes.

### `modules/eks-cluster`

Creates the EKS cluster, cluster security group, optional KMS encryption key, control plane logging, access entries, and default managed node groups.

### `modules/eks-nodegroup`

Creates additional managed node groups for an existing EKS cluster. This module is useful when node groups need to be managed independently from the cluster lifecycle.

## Prerequisites

- Terraform 1.6 or newer
- AWS CLI configured for the target AWS account
- IAM permissions to manage EKS, EC2, IAM, KMS, and CloudWatch resources
- Existing VPC and subnet IDs for the target environment
- Existing EC2 key pair if SSH access to nodes is required

## Example Workflow

From an environment directory:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Required Inputs

Each environment should provide:

- AWS region
- Cluster name
- Kubernetes version
- Existing VPC ID
- Public subnet IDs
- Private subnet IDs
- CIDR ranges allowed to access the EKS API endpoint
- Node group instance type and scaling settings
- EC2 key pair name, if SSH access is required
- Tags for environment, product, owner, and cost allocation

## Security Notes

- Restrict `external_access_cidrs` to trusted office, VPN, or bastion IP ranges.
- Avoid committing generated kubeconfig files, Terraform state files, or real account-specific values.
- Use least-privilege IAM policies for production usage.
- Enable KMS encryption for Kubernetes secrets in production environments.
- Review public endpoint access before exposing a cluster API endpoint.

## Presentation Notes

This sample demonstrates modular Terraform design, EKS infrastructure composition, environment-specific configuration, launch template customization, tagging strategy, and basic platform security controls.
