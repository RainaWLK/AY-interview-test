variable "env" {}
variable "region" {}

variable "cluster_name" {}
variable "eks_version" {}


variable "vpc_cidr" {
  type = string
}
variable "public_subnet_cidrs" {
  type = map(string)
}
variable "node_subnet_cidrs" {
  type = map(string)
}
variable "pod_subnet_cidrs" {
  type = map(string)
}
variable "db_subnet_cidrs" {
  type = map(string)
}
variable "eks_control_plane_subnet_cidrs" {
  type    = map(string)
  default = {
    "ap-northeast-1a" = "10.0.255.0/28"
    "ap-northeast-1b" = "10.0.255.16/28"
    "ap-northeast-1c" = "10.0.255.32/28"
  }
}

variable "service_cidr" {
  type        = string
  default     = "192.168.0.0/24"
}

# variable "pod_cidr" {
#   type        = string
#   default     = "172.16.0.0/16"
# }

