env="dev"
region="ap-northeast-1"
cluster_name="my-eks-cluster"
eks_version="1.34"
vpc_cidr="10.0.0.0/16"

public_subnet_cidrs = {
  "ap-northeast-1a" = "10.0.1.0/24"
  "ap-northeast-1b" = "10.0.2.0/24"
  "ap-northeast-1c" = "10.0.3.0/24"
}
node_subnet_cidrs = {
  "ap-northeast-1a" = "10.0.11.0/24"
  "ap-northeast-1b" = "10.0.12.0/24"
  "ap-northeast-1c" = "10.0.13.0/24"
}
pod_subnet_cidrs = {
  "ap-northeast-1a" = "10.0.112.0/20"
  "ap-northeast-1b" = "10.0.128.0/20"
  "ap-northeast-1c" = "10.0.144.0/20"
}
db_subnet_cidrs = {
  "ap-northeast-1a" = "10.0.20.0/24"
  "ap-northeast-1b" = "10.0.21.0/24"
  "ap-northeast-1c" = "10.0.22.0/24"
}