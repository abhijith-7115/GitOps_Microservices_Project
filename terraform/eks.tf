#############----EKS NODE GROUP SECURITY GROUP----##################
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${local.name}-eks-node-sg"
  description = "Allow SSH access to EKS nodes"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-eks-node-group-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_ssh" {
  security_group_id            = aws_security_group.eks_nodes_sg.id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "eks_nodes_outbound" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


#############----EKS CLUSTER MODULE----##################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                         = local.name
  kubernetes_version           = "1.31"
  endpoint_public_access       = false # KEEPING THE API PRIVATE
  endpoint_public_access_cidrs = []
  endpoint_private_access      = true

  # DISABLE AUTO-MODE
  compute_config = {
    enabled = false
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # ----------------------------------------------------
  # ACCESS ENTRIES (Explicit IAM User)
  # ----------------------------------------------------

  enable_cluster_creator_admin_permissions = false

  access_entries = {
    admin = {
      principal_arn = var.eks_admin_user_arn

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # ----------------------------------------------------
  # CLUSTER SECURITY GROUP RULES
  # ----------------------------------------------------

  security_group_additional_rules = {
    access_for_bastion_jenkins_hosts = {
      description = "Allow HTTPS/API access to the EKS Control Plane from the entire VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      type        = "ingress"
    }
  }

  # ----------------------------------------------------
  # EKS ADD-ONS
  # ----------------------------------------------------

  # ----------------------------------------------------
  # EKS ADD-ONS
  # ----------------------------------------------------

  addons = {
    # CoreDNS: Internal DNS so microservices find each other by name
    coredns = {
      most_recent = true
    }

    # Kube-Proxy: Maintains network routing rules on worker nodes
    "kube-proxy" = {
      most_recent = true
    }

    # Amazon VPC CNI: Assigns native AWS VPC IPs directly to your Pods
    "vpc-cni" = {
      most_recent    = true
      before_compute = true
    }

    # EKS Pod Identity Agent: Allows Pods to securely assume AWS IAM roles
    "eks-pod-identity-agent" = {
      most_recent    = true
      before_compute = true
    }
  }

  # ----------------------------------------------------
  # MANAGED NODE GROUPS 
  # ----------------------------------------------------

  eks_managed_node_groups = {
    app_nodes = {
      min_size     = 2
      max_size     = 5
      desired_size = 2

      instance_types             = ["c7i-flex.large"]
      ami_type                   = "AL2023_x86_64_STANDARD"
      disk_size                  = 35
      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key               = var.key_pair
        source_security_group_ids = [aws_security_group.eks_nodes_sg.id]
      }

      tags = {
        Name        = "${local.name}-worker-node"
        Environment = var.my_environment
      }
    }
  }
}


# ----------------------------------------------------
# FETCH WORKER NODE IPs
# ----------------------------------------------------
data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.eks]
}
