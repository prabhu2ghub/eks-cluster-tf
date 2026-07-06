
resource "aws_eks_cluster" "mytf_eks_cluster" {
  name                = local.name
  role_arn            = data.aws_iam_role.eks.arn
  version             = var.eks_k8s_version
  deletion_protection = var.delete_protection
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = "true"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    security_group_ids      = [aws_security_group.eks.id]
    subnet_ids              = concat(data.aws_subnet.public[*].id, data.aws_subnet.private[*].id)
    endpoint_private_access = true
    public_access_cidrs     = var.external_access_cidrs
    #checkov:skip=CKV_AWS_39:we're using this public endpoint for bootstrapping from external systems
    endpoint_public_access = true
  }
  # trivy doesn't detect secret encryption properly here
  dynamic "encryption_config" {
    for_each = local.kms_keys

    content {
      provider {
        key_arn = encryption_config.value
      }
      resources = ["secrets"]
    }
  }

  tags = merge({ Name = local.name }, local.eks_cluster_tags)

  depends_on = [aws_kms_key.kms_key, aws_cloudwatch_log_group.eks_cluster_loggroup]
}

resource "aws_iam_openid_connect_provider" "mytf_oicp" {
  url = aws_eks_cluster.mytf_eks_cluster.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280", "06b25927c42a721631c1efd9431e648fa62e1e39"]
}

resource "aws_cloudwatch_log_group" "eks_cluster_loggroup" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name = "/aws/eks/${local.name}/cluster"
  #checkov:skip=CKV_AWS_338:we don't need a year of cloudwatch logs for this demo
  retention_in_days = 7
  kms_key_id        = length(local.created_key_arn) > 0 ? local.created_key_arn[0] : null

  depends_on = [aws_kms_key.kms_key]
}

# install calico networking
resource "null_resource" "calico" {
  count = var.use_calico_networking ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
kubectl delete daemonset aws-node -n kube-system
kubectl apply -f https://docs.projectcalico.org/manifests/calico-vxlan.yaml
EOF


    environment = {
      KUBECONFIG = local_file.kubeconfig.filename
    }
  }
}

resource "aws_eks_access_entry" "cluster_admin" {
  for_each = toset(var.cluster_admin_principal_arns)

  cluster_name  = aws_eks_cluster.mytf_eks_cluster.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  for_each = {
    for pair in setproduct(var.cluster_admin_principal_arns, var.policy_arns) :
    "${pair[0]}:${pair[1]}" => {
      principal_arn = pair[0]
      policy_arn    = pair[1]
    }
  }

  cluster_name  = aws_eks_cluster.mytf_eks_cluster.name
  policy_arn    = each.value.policy_arn
  principal_arn = each.value.principal_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_node_group" "mytf_eks_node_group" {
  count = var.node_group_count

  cluster_name    = aws_eks_cluster.mytf_eks_cluster.name
  node_group_name = "${aws_eks_cluster.mytf_eks_cluster.name}grp${count.index}"
  node_role_arn   = data.aws_iam_role.eks_worker.arn
  subnet_ids      = data.aws_subnet.private[*].id

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
  labels = {
    NodeGroup = "${aws_eks_cluster.mytf_eks_cluster.name}grp${count.index}"
  }
  tags = merge({ Name = "${aws_eks_cluster.mytf_eks_cluster.name}grp${count.index}" }, local.eks_node_group_tags)

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [null_resource.calico]
}

resource "local_file" "kubeconfig" {
  filename = "${path.root}/outputs/${local.name}_kube_config_cluster.yml"
  content  = local.kubeconfig

  directory_permission = "0750"
  file_permission      = "0640"

  depends_on = [aws_eks_cluster.mytf_eks_cluster]
}

resource "aws_launch_template" "mytf_eks_node_lt" {
  count = var.node_group_count

  image_id               = local.ami_id
  instance_type          = var.node_group_instance_type
  update_default_version = true
  key_name               = var.ec2key_name
  user_data = base64encode(templatefile(
    "${var.node_lt_path}",
    {
      cluster_name     = aws_eks_cluster.mytf_eks_cluster.name
      cluster_endpoint = aws_eks_cluster.mytf_eks_cluster.endpoint
      cluster_ca       = aws_eks_cluster.mytf_eks_cluster.certificate_authority[0].data
      nodegroup_name   = "${aws_eks_cluster.mytf_eks_cluster.name}grp${count.index}"
      ami_id           = local.ami_id
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
      aws_eks_cluster.mytf_eks_cluster.vpc_config[0].cluster_security_group_id
    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge({ Name = "${aws_eks_cluster.mytf_eks_cluster.name}grp${count.index}" }, local.eks_node_group_tags)
  }

  tags = {
    "eks:cluster-name"   = aws_eks_cluster.mytf_eks_cluster.name
    "eks:nodegroup-name" = "${aws_eks_cluster.mytf_eks_cluster.name}grp${count.index}"
  }
}
