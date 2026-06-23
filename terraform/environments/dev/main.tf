module "iam" {
  source = "../../modules/iam"

  cluster_name = var.cluster_name
}

module "vpc" {
  source                                 = "../../modules/vpc"
  vpc_name                               = var.vpc_name
  vpc_cidr_block                         = var.vpc_cidr_block
  vpc_public_subnets                     = var.vpc_public_subnets
  vpc_private_subnets                    = var.vpc_private_subnets
  vpc_database_subnets                   = var.vpc_database_subnets
  vpc_create_database_subnet_group       = var.vpc_create_database_subnet_group
  vpc_create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  vpc_enable_nat_gateway                 = var.vpc_enable_nat_gateway
  vpc_single_nat_gateway                 = var.vpc_single_nat_gateway

  cluster_name = var.cluster_name
  common_tags  = var.common_tags

}

module "eks" {
  source = "../../modules/eks"

  cluster_name                         = var.cluster_name
  cluster_version                      = var.cluster_version
  cluster_service_ipv4_cidr            = var.cluster_service_ipv4_cidr
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  node_instance_type   = var.node_instance_type
  node_desired_size    = var.node_desired_size
  node_min_size        = var.node_min_size
  node_max_size        = var.node_max_size
  node_ami_type        = var.node_ami_type
  node_disk_size       = var.node_disk_size
  node_max_unavailable = var.node_max_unavailable

  cluster_iam_role_arn = module.iam.cluster_iam_role_arn
  vpc_public_subnets   = module.vpc.public_subnets

  eks_clusterpolicy_id           = module.iam.eks_clusterpolicy_id
  eks_vpc_resource_controller_id = module.iam.eks_vpc_resource_controller_id
  eks_nodegroup_role_arn         = module.iam.eks_nodegroup_role_arn
}

module "alb_controller" {
  source = "../../modules/alb-controller"

  project_name    = var.business_department
  oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  cluster_name    = var.cluster_name

  aws_region        = var.aws_region
  public_subnet_ids = module.vpc.public_subnets
  vpc_id            = module.vpc.vpc_id


  depends_on = [
    module.eks,
    module.vpc
  ]

}
