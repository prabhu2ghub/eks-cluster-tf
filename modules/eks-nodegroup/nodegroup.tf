resource "aws_launch_template" "mytf_eks_node_lt" {
  count                  = var.node_group_count
  image_id               = var.ami_id
  instance_type          = var.node_group_instance_type
  update_default_version = true
  key_name               = var.ec2key_name
  user_data = base64encode(templatefile(
    "${var.node_lt_path}",
    {
      cluster_name     = var.cluster_name
      cluster_endpoint = data.aws_eks_cluster.mytf_eks_cluster.endpoint
      cluster_ca       = data.aws_eks_cluster.mytf_eks_cluster.certificate_authority[0].data
      nodegroup_name   = var.node_group_name
      ami_id           = var.ami_id
      docker_mirror    = var.docker_mirror
    }
  ))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = "true"
      volume_size           = var.node_group_disk_size
      volume_type           = "gp3"
      encrypted             = "true"
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    #checkov:skip=CKV_AWS_341:we're easy-buttoning the access for containers to hit the API
    http_put_response_hop_limit = 2
  }

  network_interfaces {
    security_groups = [
      data.aws_eks_cluster.mytf_eks_cluster.vpc_config[0].cluster_security_group_id
    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge({ Name = var.node_group_name }, var.eks_node_group_tags)
  }

  tags = {
    "eks:cluster-name"   = var.cluster_name
    "eks:nodegroup-name" = var.node_group_name
  }
}
resource "aws_eks_node_group" "mytf_eks_node_group" {
  count           = var.node_group_count
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = data.aws_iam_role.eks_worker.arn
  subnet_ids      = var.private_subnet_ids

  force_update_version = var.force_update_version

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  launch_template {
    id      = aws_launch_template.mytf_eks_node_lt[count.index].id
    version = aws_launch_template.mytf_eks_node_lt[count.index].latest_version
  }

  tags = merge({ Name = var.node_group_name }, var.eks_node_group_tags)
  labels = {
    NodeGroup = var.node_group_name
  }
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [null_resource.calico]

  dynamic "taint" {
    for_each = var.node_taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}


# install calico networking
resource "null_resource" "calico" {
  count = var.use_calico_networking ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
kubectl delete daemonset aws-node -n kube-system
kubectl apply -f https://docs.projectcalico.org/manifests/calico-vxlan.yaml
EOF
  }
}
