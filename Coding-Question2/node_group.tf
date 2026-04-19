resource "aws_eks_node_group" "kube_system" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "kube_system"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.node[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "services" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "services"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.node[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "db" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "db"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.db[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
}