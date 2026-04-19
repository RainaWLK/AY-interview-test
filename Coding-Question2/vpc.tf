resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key

  tags = {
    Name                                        = "${var.env}-${each.key}-public"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = "1"
    Tier                                        = "public"
  }
}

resource "aws_subnet" "node" {
  for_each = var.node_subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.env}-${each.key}-node"    
    Tier = "node"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "pod" {
  for_each = var.pod_subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.env}-${each.key}-pod"
    Tier = "pod"
  }
}

resource "aws_subnet" "db" {
  for_each = var.db_subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.env}-${each.key}-db"
    Tier = "db"
  }
}

resource "aws_subnet" "eks_control_plane" {
  for_each = var.eks_control_plane_subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.env}-${each.key}-eks-control-plane"
    Tier = "eks-control-plane"
  }
}

# ------------------------- Gateways -----------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { 
    Name = "${var.env}-vpc-igw"
  }
}

resource "aws_eip" "nat_gw" {
  for_each = var.node_subnet_cidrs
  domain = "vpc"
  tags   = { 
    Name = "${var.env}-vpc-nat-gw-${each.key}"
  }
}

resource "aws_nat_gateway" "main" {
  for_each = var.node_subnet_cidrs

  allocation_id = aws_eip.nat_gw[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = { 
    Name = "${var.env}-vpc-nat-gw-${each.key}"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}

# --------------------- route ------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = {
    Name = "${var.env}-vpc-public"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  for_each = var.public_subnet_cidrs

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  for_each = var.node_subnet_cidrs

  vpc_id = aws_vpc.main.id
  tags   = {
    Name = "${var.env}-vpc-private-${each.key}"
  }
}

resource "aws_route" "private" {
  for_each = var.node_subnet_cidrs

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[each.key].id
}

resource "aws_route_table_association" "node" {
  for_each = var.node_subnet_cidrs

  subnet_id      = aws_subnet.node[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "pod" {
  for_each = var.pod_subnet_cidrs

  subnet_id      = aws_subnet.pod[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "db" {
  for_each = var.db_subnet_cidrs

  subnet_id      = aws_subnet.db[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "eks_cp" {
  for_each = var.eks_control_plane_subnet_cidrs

  subnet_id      = aws_subnet.eks_control_plane[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# ------------- vpc endpoints ------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
}