module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.34"

  endpoint_public_access = false
  enable_cluster_creator_admin_permissions = true

  service_ipv4_cidr = "192.168.0.0/24"

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public["*"].id
  control_plane_subnet_ids = aws_subnet.eks_control_plane["*"].id

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
    aws_ebs_csi_driver = {}
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


