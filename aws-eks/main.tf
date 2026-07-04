# Region
data "aws_region" "region" {}

module "eks_vpc" {
  source  = "terraform-aws-modules/vpc/aws" # AWS VPC module (supported by community)
  version = "6.6.1"

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr
  azs  = formatlist("${data.aws_region.region.region}%s", var.vpc_availability_zones)

  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  # One NAT Gateway per availability zone
  # Each private subnet will route Internet traffic through the corresponding NAT gateway in the public subnet
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # Tags for EKS load balancers
  # See: https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1 # Use internal load balancers
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1 # Use external load balancers
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws" # AWS EKS module (supported by community)
  version = "21.23.0"

  name               = var.name
  kubernetes_version = var.eks_version

  vpc_id     = module.eks_vpc.vpc_id
  subnet_ids = module.eks_vpc.private_subnets

  # Public API server endpoint is enabled
  endpoint_public_access = true

  # Node groups
  eks_managed_node_groups = {
    for node_group in var.eks_node_groups : node_group.name => {
      instance_types = [node_group.instance_type]

      min_size     = node_group.min_size
      max_size     = node_group.max_size
      desired_size = node_group.desired_size
    }
  }
}
