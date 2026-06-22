module "vpc" {
  source                     = "../modules/vpc"
  vpc_name                   = var.vpc_name
  vpc_cidr_block             = var.vpc_cidr_block
  vpc_public_subnets         = var.vpc_public_subnets
  vpc_private_subnets        = var.vpc_private_subnets
  vpc_database_subnets       = var.vpc_database_subnets
  vpc_create_database_subnet = var.vpc_create_database_subnet
}

module "eks" {
  source                     = "../modules/eks"
  vpc_name                   = var.vpc_name
  vpc_cidr_block             = var.vpc_cidr_block
  vpc_public_subnets         = var.vpc_public_subnets
  vpc_private_subnets        = var.vpc_private_subnets
  vpc_database_subnets       = var.vpc_database_subnets
  vpc_create_database_subnet = var.vpc_create_database_subnet
}
