# TODO: cluster security groups, node security groups, pod security groups, db security groups

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.eks.node_security_group_id
    }
  ]
}

module "sg_rules_for_alb_to_node" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  create_sg         = false
  security_group_id = module.eks.node_security_group_id

  ingress_with_source_security_group_id = [
    {
      description              = "Allow ALB to reach Pods directly (using IP mode)"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
}